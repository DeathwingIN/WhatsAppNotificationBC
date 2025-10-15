codeunit 50106 "WhatsApp Management"
{
    // This procedure will contain our logic. It takes the posted invoice as an input.
    procedure SendWhatsAppReminder(PostSalesInvoice: Record "Sales Invoice Header")
    var
        CustomerRec: Record Customer;
        JsonPayload: JsonObject;
        JsonText: Text;

    begin
        // Find the customer related to the posted sales invoice
        if not CustomerRec.Get(PostSalesInvoice."Sell-to Customer No.") then
            Error('Could not find the customer record for this invoice.');

        // Stop if Mobile No. is empty
        if CustomerRec."Mobile Phone No." = '' then
            Error('Customer does not have a mobile phone number.');

        // Construct the JSON payload
        JsonPayload.Add('CustomerName', CustomerRec.Name);
        JsonPayload.Add('MobileNo', CustomerRec."Mobile Phone No.");
        JsonPayload.Add('InvoiceNo', PostSalesInvoice."No.");
        JsonPayload.Add('Amount', PostSalesInvoice."Amount Including VAT");
        JsonPayload.Add('DueDate', Format(PostSalesInvoice."Due Date", 0, 9));

        // Convert JSON object to text
        JsonPayload.WriteTo(JsonText);

        Message(JsonText);
    end;



}
