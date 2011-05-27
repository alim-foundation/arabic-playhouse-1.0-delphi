unit Prayers;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, EPGfxCmp, RXCtrls, SpeedBar, Arabic, ExtCtrls;

type
  TSmallPrayersForm = class(TForm)
    pnlMasterContainer: TPanel;
    btnModuleStop: TRxSpeedButton;
    pnlArabicWord: TPanel;
    awActiveWord: TArabicWordButton;
    barSelections: TSpeedBar;
    lblPageTitle: TRxLabel;
    imgBismillah: TEPImage;
    pnlTranslation: TPanel;
    lblTranslation: TRxLabel;
    procedure btnModuleStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WhenStrMouseEnter(Sender: TObject);
    procedure WhenStrClick(Sender: TObject);
    procedure awActiveWordClick(Sender: TObject);
    procedure lblTranslationClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses ApUtils, Main, SoundsMg;

procedure TSmallPrayersForm.FormCreate(Sender: TObject);
const
  BtnHeight = 25;
  BtnWidth = 260;
var
  X, Y, I : Integer;
  P : TSmallPrayer;
  Btn : TRxSpeedButton;
  BtnTextColors : TLetterColors;
  TextColor : TColor;
begin
  MakeFullScreen(Self, pnlMasterContainer);
  awActiveWord.Tag := -1;
  lblTranslation.Tag := -1;

  ClearControls(barSelections);
  BtnTextColors := TLetterColors.Create;
  TextColor := BtnTextColors.First;
  if MainForm.Prayers.Count > 0 then begin
    X := 4;
    Y := 4;
    for I := 0 to MainForm.Prayers.Count-1 do begin
      P := MainForm.Prayers[I];

      Btn := TRxSpeedButton.Create(Self);
      Btn.Parent := barSelections;
      Btn.Font.Color := TextColor;
      Btn.Left := X;
      Btn.Top := Y;
      Btn.Width := BtnWidth;
      Btn.Height := BtnHeight;
      Btn.Caption := P.When;
      Btn.Tag := I;
      Btn.OnMouseEnter := WhenStrMouseEnter;
      Btn.OnClick := WhenStrClick;
      Btn.Flat := True;
      Btn.Transparent := True;

      Inc(Y, BtnHeight);
      TextColor := BtnTextColors.Next;
    end;
  end;
  BtnTextColors.Free;
end;

procedure TSmallPrayersForm.btnModuleStopClick(Sender: TObject);
begin
  Close;
end;

procedure TSmallPrayersForm.WhenStrClick(Sender: TObject);
var
  BtnId : Integer;
begin
  BtnId := (Sender as TRxSpeedButton).Tag;
  MainForm.PlayFmtSound('RAV%d.%d', [MainForm.PersonalityId, BtnId], False, Nil);
  MainForm.PlayFmtSound('RAA%d', [BtnId], True, Nil);
end;

procedure TSmallPrayersForm.WhenStrMouseEnter(Sender: TObject);
var
  BtnId : Integer;
  P : TSmallPrayer;
begin
  MainForm.ResSounds.PlaySound('IDW_TINK', spmAsync);
  BtnId := (Sender as TRxSpeedButton).Tag;
  P := MainForm.Prayers[BtnId];
  awActiveWord.ArabicWord := P.Arabic;
  awActiveWord.Tag := BtnId;
  lblTranslation.Tag := BtnId;
  lblTranslation.Caption := P.Translation;
end;

procedure TSmallPrayersForm.awActiveWordClick(Sender: TObject);
begin
  if (Sender as TArabicWordButton).Tag = -1 then
    Exit;

  MainForm.PlayFmtSound('RAA%d', [(Sender as TArabicWordButton).Tag], True, Nil);
end;

procedure TSmallPrayersForm.lblTranslationClick(Sender: TObject);
begin
  if (Sender as TRxLabel).Tag = -1 then
    Exit;

  MainForm.PlayFmtSound('RAT%d.%d', [MainForm.PersonalityId, (Sender as TRxLabel).Tag], True, Nil);
end;

end.
