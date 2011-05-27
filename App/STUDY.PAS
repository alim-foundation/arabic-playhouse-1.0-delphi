unit Study;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, RXCtrls, Arabic, RXSpin, ExtCtrls;

type
  TStudyForm = class(TForm)
    pnlMasterContainer: TPanel;
    pnlWord: TPanel;
    awStudyWord: TArabicWordButton;
    pnlControl: TPanel;
    lblRepeat: TRxLabel;
    btnCloseDialog: TRxSpeedButton;
    seRepeatCount: TRxSpinEdit;
    pnlCompare: TPanel;
    awCompareWord: TArabicWordButton;
    lblCompare: TRxLabel;
    procedure btnCloseDialogClick(Sender: TObject);
    procedure awStudyWordClick(Sender: TObject);
  private
    procedure SetWord(AWord : TArabicWordButton);
  public
    procedure ShowCompareWord(strWord, strReciteFile : String);

    property StudyWord : TArabicWordButton write SetWord;
  end;

implementation

{$R *.DFM}

uses VCLUtils, Main;

procedure TStudyForm.SetWord(AWord : TArabicWordButton);
begin
  awStudyWord.ArabicWord := AWord.ArabicWord;
  awStudyWord.RecitationFile := AWord.RecitationFile;
  case LettersCount(AWord.ArabicWord) of
    1 : awStudyWord.ArabicFontSize := 180;
    2 : awStudyWord.ArabicFontSize := 170;
    3 : awStudyWord.ArabicFontSize := 165;
    4 : awStudyWord.ArabicFontSize := 135;
    5..9 : awStudyWord.ArabicFontSize := 100;
    10..14 : awStudyWord.ArabicFontSize := 80;
    15..19 : awStudyWord.ArabicFontSize := 60;
    20..24 : awStudyWord.ArabicFontSize := 50;
    25..29 : awStudyWord.ArabicFontSize := 40;
  end;

  { figure out the best height }
  awStudyWord.Height := Trunc(awStudyWord.ArabicFontSize * 1.5);
  CenterControl(awStudyWord);

  MainForm.PlaySoundFile(awStudyWord.RecitationFile, True, Nil);
end;

procedure TStudyForm.ShowCompareWord(strWord, strReciteFile : String);
begin
  if strWord = '' then begin;
    pnlCompare.Visible := False;
    Exit;
  end;

  pnlCompare.Visible := True;
  awCompareWord.ArabicWord := strWord;
  awCompareWord.RecitationFile := strReciteFile;
end;

procedure TStudyForm.btnCloseDialogClick(Sender: TObject);
begin
  Close;
end;

procedure TStudyForm.awStudyWordClick(Sender: TObject);
var
  nRepeatIdx : Integer;
begin
  for nRepeatIdx := 1 to Trunc(seRepeatCount.Value) do
    MainForm.PlaySoundFile((Sender as TArabicWordButton).RecitationFile, False, Nil);
end;

end.
