table 50106 "WhatsApp Setup"
{
    Caption = 'WhatsApp Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Power Automate URL"; Text[2048])
        {
            Caption = 'Power Automate URL';
            DataClassification = EndUserIdentifiableInformation;
            ExtendedDatatype = URL;

            trigger OnValidate()
            begin
                if "Power Automate URL" <> '' then
                    if not "Power Automate URL".Contains('sig=') then
                        Error('The Power Automate URL must contain the signature parameter (sig=). Please copy the complete URL from Power Automate.');
            end;
        }
        field(3; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(4; "Timeout (seconds)"; Integer)
        {
            Caption = 'Timeout (seconds)';
            DataClassification = SystemMetadata;
            InitValue = 30;
            MinValue = 5;
            MaxValue = 300;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Boolean
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
        exit(true);
    end;
}
