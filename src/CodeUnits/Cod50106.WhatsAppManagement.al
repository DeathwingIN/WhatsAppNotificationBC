codeunit 50106 "WhatsApp Management"
{
    procedure SendWhatsAppReminder(PostedSalesInvoice: Record "Sales Invoice Header")
    var
        CustomerRec: Record Customer;
        JsonPayload: JsonObject;
        JsonText: Text;
        PowerAutomateURL: Text;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ResponseText: Text;
        Headers: HttpHeaders;
        // ---- NEW AUTHENTICATION VARIABLES ----
    // No OAuth token acquisition: using flow's HTTP trigger URL (SAS) instead
    begin
        // Using the HTTP trigger URL (SAS) configured on the flow. No OAuth flow required.

        // --- Step 3: Data Gathering (Same as your original code) ---
        if not CustomerRec.Get(PostedSalesInvoice."Sell-to Customer No.") then
            Error('Could not find the customer record for this invoice.');
        if CustomerRec."Mobile Phone No." = '' then
            Error('Customer does not have a mobile phone number.');

        JsonPayload.Add('customerName', CustomerRec.Name);
        JsonPayload.Add('mobileNumber', CustomerRec."Mobile Phone No.");
        JsonPayload.Add('invoiceNumber', PostedSalesInvoice."No.");
        JsonPayload.Add('invoiceAmount', PostedSalesInvoice."Amount Including VAT");
        JsonPayload.Add('invoiceDueDate', Format(PostedSalesInvoice."Due Date", 0, 9));
        JsonPayload.WriteTo(JsonText);

        // --- Step 4: Prepare and Send the HTTP Request (With Auth) ---
        PowerAutomateURL := 'https://14fdfc04406ee18ba16e6b863d3dcf.09.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/cbe3f87454a645558fdd0574aff4e32d/triggers/manual/paths/invoke?api-version=1'; // Your Power Automate URL

        Content.WriteFrom(JsonText);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.SetRequestUri(PowerAutomateURL);
        Request.Method := 'POST';
        Request.Content := Content;

    // No Authorization header required when calling the HTTP trigger URL (SAS)

        if not Client.Send(Request, Response) then
            Error('The call to Power Automate failed.');

        if not Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ResponseText);
            Error('Power Automate returned an error. Status: %1, Response: %2', Response.HttpStatusCode, ResponseText);
        end;

        Message('WhatsApp Reminder sent successfully to %1', CustomerRec."Mobile Phone No.");
    end;
}