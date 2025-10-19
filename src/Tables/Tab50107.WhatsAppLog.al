table 50107 "WhatsApp Log"
{
    Caption = 'WhatsApp Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(5; "Mobile No."; Text[30])
        {
            Caption = 'Mobile No.';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(6; "Sent Date Time"; DateTime)
        {
            Caption = 'Sent Date Time';
            DataClassification = SystemMetadata;
        }
        field(7; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(8; "Status"; Enum "WhatsApp Log Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(9; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

enum 50106 "WhatsApp Log Status"
{
    Extensible = true;

    value(0; Success)
    {
        Caption = 'Success';
    }
    value(1; Failed)
    {
        Caption = 'Failed';
    }
}
