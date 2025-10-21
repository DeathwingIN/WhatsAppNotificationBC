codeunit 50106 "WhatsApp Management"
{
    procedure SendWhatsAppReminder(PostedSalesInvoice: Record "Sales Invoice Header")
    var
        CustomerRec: Record Customer;
        WhatsAppSetup: Record "WhatsApp Setup";
        WhatsAppLog: Record "WhatsApp Log";
        JsonPayload: JsonObject;
        JsonText: Text;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ResponseText: Text;
        Headers: HttpHeaders;
        ErrorMsg: Text;
        ResponseJson: JsonObject;
        MessageIdToken: JsonToken;
        MessageId: Text;
    begin
        // Validate setup
        if not WhatsAppSetup.GetSetup() then
            Error('WhatsApp setup is not configured. Please configure it in WhatsApp Setup page.');

        if not WhatsAppSetup.Enabled then
            Error('WhatsApp notifications are disabled. Please enable it in WhatsApp Setup page.');

        if WhatsAppSetup."Power Automate URL" = '' then
            Error('Power Automate URL is not configured. Please configure it in WhatsApp Setup page.');

        // Validate customer
        if not CustomerRec.Get(PostedSalesInvoice."Sell-to Customer No.") then
            Error('Customer record not found.');

        if CustomerRec."Mobile Phone No." = '' then
            Error('Customer does not have a mobile phone number.');

        if not ValidateMobileNumber(CustomerRec."Mobile Phone No.") then
            Error('Customer mobile phone number is invalid.');

        // Confirm before sending
        if not Confirm('Do you want to send a WhatsApp reminder to %1 (%2)?', false, CustomerRec.Name, CustomerRec."Mobile Phone No.") then
            exit;

        // Prepare payload
        JsonPayload.Add('customerName', CustomerRec.Name);
        JsonPayload.Add('mobileNumber', CustomerRec."Mobile Phone No.");
        JsonPayload.Add('invoiceNumber', PostedSalesInvoice."No.");
        JsonPayload.Add('invoiceAmount', PostedSalesInvoice."Amount Including VAT");
        JsonPayload.Add('invoiceDueDate', Format(PostedSalesInvoice."Due Date", 0, 9));
        JsonPayload.WriteTo(JsonText);

        // Prepare HTTP request
        Content.WriteFrom(JsonText);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.SetRequestUri(WhatsAppSetup."Power Automate URL");
        Request.Method := 'POST';
        Request.Content := Content;

        // Set timeout
        Client.Timeout(WhatsAppSetup."Timeout (seconds)" * 1000);

        // Initialize log entry
        InitializeLogEntry(WhatsAppLog, PostedSalesInvoice, CustomerRec);

        // Send request
        if not Client.Send(Request, Response) then begin
            ErrorMsg := 'Failed to send WhatsApp message. Please check your internet connection.';
            LogError(WhatsAppLog, ErrorMsg);
            Error(ErrorMsg);
        end;

        if not Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ResponseText);
            ErrorMsg := StrSubstNo('Failed to send WhatsApp message. Status code: %1', Response.HttpStatusCode);
            LogError(WhatsAppLog, ErrorMsg);
            Error(ErrorMsg);
        end;

        // Parse response to get message ID
        Response.Content().ReadAs(ResponseText);
        MessageId := ''; // Initialize as empty

        if ResponseText <> '' then begin
            if ResponseJson.ReadFrom(ResponseText) then begin
                if ResponseJson.Get('messageId', MessageIdToken) then
                    MessageId := MessageIdToken.AsValue().AsText()
                else
                    MessageId := CreateGuid(); // Generate fallback ID
            end;
        end else
            MessageId := CreateGuid(); // Generate fallback ID if no response body

        // Log as Sent (not success yet)
        LogSent(WhatsAppLog, MessageId);
        Message('WhatsApp reminder sent to Power Automate for %1. Delivery status will be updated.', CustomerRec."Mobile Phone No.");
    end;

    local procedure ValidateMobileNumber(MobileNo: Text): Boolean
    var
        CleanNumber: Text;
        i: Integer;
    begin
        if MobileNo = '' then
            exit(false);

        CleanNumber := DelChr(MobileNo, '=', ' ()-+');

        if StrLen(CleanNumber) < 10 then
            exit(false);

        for i := 1 to StrLen(CleanNumber) do
            if not (CleanNumber[i] in ['0' .. '9']) then
                exit(false);

        exit(true);
    end;

    local procedure InitializeLogEntry(var WhatsAppLog: Record "WhatsApp Log"; PostedSalesInvoice: Record "Sales Invoice Header"; CustomerRec: Record Customer)
    begin
        WhatsAppLog.Init();
        WhatsAppLog."Document No." := PostedSalesInvoice."No.";
        WhatsAppLog."Customer No." := CustomerRec."No.";
        WhatsAppLog."Mobile No." := CustomerRec."Mobile Phone No.";
        WhatsAppLog."Sent Date Time" := CurrentDateTime;
        WhatsAppLog."User ID" := CopyStr(UserId, 1, MaxStrLen(WhatsAppLog."User ID"));
    end;

    local procedure LogSent(var WhatsAppLog: Record "WhatsApp Log"; MessageId: Text)
    begin
        WhatsAppLog.Status := WhatsAppLog.Status::Delivered; // Changed from Sent to Delivered
        WhatsAppLog."Message ID" := CopyStr(MessageId, 1, MaxStrLen(WhatsAppLog."Message ID"));
        WhatsAppLog.Insert(true);
        Commit();
    end;

    local procedure LogError(var WhatsAppLog: Record "WhatsApp Log"; ErrorMessage: Text)
    begin
        WhatsAppLog.Status := WhatsAppLog.Status::Failed;
        WhatsAppLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(WhatsAppLog."Error Message"));
        WhatsAppLog.Insert(true);
        Commit();
    end;
}