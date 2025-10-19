page 50106 "WhatsApp Setup"
{
    Caption = 'WhatsApp Setup';
    PageType = Card;
    SourceTable = "WhatsApp Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable or disable WhatsApp notifications';
                }
                field("Power Automate URL"; Rec."Power Automate URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the complete Power Automate webhook URL including the signature parameter. Copy the entire URL from Power Automate without any modifications.';
                    ExtendedDatatype = Masked;
                    MultiLine = true;
                }
                field("Timeout (seconds)"; Rec."Timeout (seconds)")
                {
                    ApplicationArea = All;
                    ToolTip = 'HTTP request timeout in seconds';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ViewLog)
            {
                Caption = 'View Log';
                ToolTip = 'View WhatsApp message history';
                Image = Log;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.Run(Page::"WhatsApp Log");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
