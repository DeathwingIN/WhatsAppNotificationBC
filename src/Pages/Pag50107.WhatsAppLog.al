page 50107 "WhatsApp Log"
{
    Caption = 'WhatsApp Log';
    PageType = List;
    SourceTable = "WhatsApp Log";
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the message was sent successfully';
                    StyleExpr = StatusStyle;
                }
                field("Sent Date Time"; Rec."Sent Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the message was sent';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoice number';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number';
                }
                field("Mobile No."; Rec."Mobile No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mobile number the message was sent to';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who sent the message';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message if the send failed';
                    Visible = ShowErrors;
                }
            }
        }
        area(factboxes)
        {
            part(ErrorDetails; "WhatsApp Log FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowAllEntries)
            {
                Caption = 'Show All';
                ToolTip = 'Show all log entries';
                Image = List;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.Reset();
                    ShowErrors := false;
                    CurrPage.Update(false);
                end;
            }
            action(ShowFailedOnly)
            {
                Caption = 'Show Failed Only';
                ToolTip = 'Show only failed messages';
                Image = ErrorLog;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange(Status, Rec.Status::Failed);
                    ShowErrors := true;
                    CurrPage.Update(false);
                end;
            }
            action(ShowSuccessOnly)
            {
                Caption = 'Show Success Only';
                ToolTip = 'Show only successful messages';
                Image = Approve;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetRange(Status, Rec.Status::Success);
                    ShowErrors := false;
                    CurrPage.Update(false);
                end;
            }
            action(RefreshLog)
            {
                Caption = 'Refresh';
                ToolTip = 'Refresh the log';
                Image = Refresh;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
        area(navigation)
        {
            action(OpenInvoice)
            {
                Caption = 'Open Invoice';
                ToolTip = 'Open the related posted sales invoice';
                Image = Invoice;
                ApplicationArea = All;

                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Invoice Header";
                begin
                    if Rec."Document No." = '' then
                        Error('No document number specified.');

                    if not SalesInvoiceHeader.Get(Rec."Document No.") then
                        Error('Invoice %1 not found.', Rec."Document No.");

                    Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
                end;
            }
            action(OpenCustomer)
            {
                Caption = 'Open Customer';
                ToolTip = 'Open the customer card';
                Image = Customer;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Rec."Customer No." = '' then
                        Error('No customer number specified.');

                    if not Customer.Get(Rec."Customer No.") then
                        Error('Customer %1 not found.', Rec."Customer No.");

                    Page.Run(Page::"Customer Card", Customer);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Success:
                StatusStyle := 'Favorable';
            Rec.Status::Failed:
                StatusStyle := 'Unfavorable';
        end;
    end;

    var
        StatusStyle: Text;
        ShowErrors: Boolean;
}
