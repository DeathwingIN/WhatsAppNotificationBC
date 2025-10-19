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

            action(ViewWhatsAppLog)
            {
                Caption = 'WhatsApp Log';
                ToolTip = 'View WhatsApp message history for this invoice';
                Image = Log;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WhatsAppLog: Record "WhatsApp Log";
                begin
                    WhatsAppLog.SetRange("Document No.", Rec."No.");
                    Page.Run(Page::"WhatsApp Log", WhatsAppLog);
                end;
            }
        }
    }
}
