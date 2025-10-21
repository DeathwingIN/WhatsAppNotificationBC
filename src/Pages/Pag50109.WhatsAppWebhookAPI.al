page 50109 "WhatsApp Webhook API"
{
    PageType = API;
    APIPublisher = 'YourCompany';
    APIGroup = 'whatsapp';
    APIVersion = 'v1.0';
    EntityName = 'whatsappWebhook';
    EntitySetName = 'whatsappWebhooks';
    SourceTable = "WhatsApp Log";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            field(messageId; MessageIdInput)
            {
                Caption = 'Message ID';
            }
            field(status; StatusInput)
            {
                Caption = 'Status';
            }
            field(errorMessage; ErrorMessageInput)
            {
                Caption = 'Error Message';
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        WhatsAppWebhook: Codeunit "WhatsApp Webhook";
    begin
        WhatsAppWebhook.UpdateMessageStatus(MessageIdInput, StatusInput, ErrorMessageInput);
        exit(false); // Don't insert new record
    end;

    var
        MessageIdInput: Text[100];
        StatusInput: Text[50];
        ErrorMessageInput: Text[250];
}
