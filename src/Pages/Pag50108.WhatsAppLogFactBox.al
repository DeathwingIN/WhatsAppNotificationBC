page 50108 "WhatsApp Log FactBox"
{
    Caption = 'Message Details';
    PageType = CardPart;
    SourceTable = "WhatsApp Log";

    layout
    {
        area(content)
        {
            group(Details)
            {
                ShowCaption = false;

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the message';
                    StyleExpr = StatusStyle;
                }
                field("Sent Date Time"; Rec."Sent Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the message was sent';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who sent the message';
                }
            }
            group(ErrorInfo)
            {
                Caption = 'Error Information';
                Visible = Rec.Status = Rec.Status::Failed;

                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message';
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Delivered,
            Rec.Status::Read:
                StatusStyle := 'Favorable';
            Rec.Status::Failed:
                StatusStyle := 'Unfavorable';
            Rec.Status::Pending,
            Rec.Status::Sent:
                StatusStyle := 'Ambiguous';
        end;
    end;

    var
        StatusStyle: Text;
}
