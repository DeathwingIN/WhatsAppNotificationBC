codeunit 50107 "WhatsApp Webhook"
{
    procedure UpdateMessageStatus(MessageId: Text; Status: Text; ErrorMessage: Text)
    var
        WhatsAppLog: Record "WhatsApp Log";
        NewStatus: Enum "WhatsApp Log Status";
    begin
        // Find log entry by Message ID
        WhatsAppLog.SetRange("Message ID", MessageId);
        if not WhatsAppLog.FindFirst() then
            exit;

        // Convert status text to enum
        case LowerCase(Status) of
            'delivered':
                NewStatus := WhatsAppLog.Status::Delivered;
            'read':
                NewStatus := WhatsAppLog.Status::Read;
            'failed':
                NewStatus := WhatsAppLog.Status::Failed;
            else
                exit;
        end;

        // Update log entry
        WhatsAppLog.Status := NewStatus;
        if ErrorMessage <> '' then
            WhatsAppLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(WhatsAppLog."Error Message"));
        WhatsAppLog.Modify(true);
        Commit();
    end;
}
