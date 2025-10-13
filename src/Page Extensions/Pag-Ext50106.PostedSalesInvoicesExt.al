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

                trigger OnAction()
                begin
                    Message('WhatsApp Reminder clicked for Invoice No. %1', Rec."No.");
                end;
            }
        }
    }
}
