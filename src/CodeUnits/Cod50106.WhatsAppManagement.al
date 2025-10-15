codeunit 50106 "WhatsApp Management"
{
    // This procedure will contain our logic. It takes the posted invoice as an input.
    procedure SendWhatsAppReminder(PostSalesInvoice: Record "Sales Invoice Header")
    var
        CustomerRec: Record Customer;
        JsonPayload: JsonObject;
        JsonText: Text;
        PowerAutomateURL: Text;
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        ResponseText: Text;


    begin
        // Find the customer related to the posted sales invoice
        if not CustomerRec.Get(PostSalesInvoice."Sell-to Customer No.") then
            Error('Could not find the customer record for this invoice.');

        // Stop if Mobile No. is empty
        if CustomerRec."Mobile Phone No." = '' then
            Error('Customer does not have a mobile phone number.');

        // Construct the JSON payload
        JsonPayload.Add('customerName', CustomerRec.Name);
        JsonPayload.Add('mobileNumber', CustomerRec."Mobile Phone No.");
        JsonPayload.Add('invoiceNumber', PostSalesInvoice."No.");
        JsonPayload.Add('invoiceAmount', PostSalesInvoice."Amount Including VAT");
        JsonPayload.Add('invoiceDueDate', Format(PostSalesInvoice."Due Date", 0, 9));
        // Convert JSON object to text
        JsonPayload.WriteTo(JsonText);

        // Call Power Automate Flow
        PowerAutomateURL := 'https://14fdfc04406ee18ba16e6b863d3dcf.09.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/cbe3f87454a645558fdd0574aff4e32d/triggers/manual/paths/invoke?api-version=1'

        // Prepare HTTP request
        Content.WriteFrom(JsonText);
        Content.GetHeaders(Request.Content.Headers);
        Request.Content.Headers.Clear();
        Request.Content.Headers.Add('Content-Type', 'application/json');

        // Set the request method to POST and provide the URL.
        Request.SetRequestUri(PowerAutomateURL);
        Request.Method := 'POST';
        Request.Content := Content;

        // Send HTTP request
        if not Client.Send(Request, Response) then
            Error('The call to Power Automate failed.');

        // Check Response
        if not Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ResponseText);
            Error('Power Automate returned an error. Status: %1, Response: %2', Response.HttpStatusCode, ResponseText);
        end;

        // Success message
        Message('WhatsApp Reminder sent successfully to %1', CustomerRec."Mobile Phone No.");
    end;



}
