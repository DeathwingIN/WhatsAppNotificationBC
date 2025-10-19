pageextension 50106 PostedSalesInvoicesExt extends "Posted Sales Invoices"
{
    //Add whats app action after print action
    actions
    {
        addlast(processing)
        {
            action(SendWhatsAppReminder)
            {
                Caption = 'Send WhatsApp Reminder';
                ToolTip = 'Send WhatsApp Reminder to Customer';

                Image = SendTo;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WhatsAppMgmt: Codeunit "WhatsApp Management";
                begin
                    WhatsAppMgmt.SendWhatsAppReminder(Rec);
                end;
            }
        }
    }
}
