program Aplay;

uses
  Forms,
  Dialogs,
  Controls,
  WinTypes,
  WinProcs,
  Arabic,
  Words in 'WORDS.PAS' {WordsForm},
  Main in 'MAIN.PAS' {MainForm},
  Soundsmg in 'SOUNDSMG.PAS',
  Quran in 'QURAN.PAS' {QuranForm},
  Study in 'STUDY.PAS' {StudyForm},
  Prayers in 'PRAYERS.PAS' {SmallPrayersForm},
  About in 'ABOUT.PAS' {AboutBox},
  Errorfrm in '\PROJECTS\DELPHI\16-BIT\ERRORFRM.PAS' {Errors},
  SysUtils, StUtils, ApUtils;

{$R *.RES}

begin
  if GetDiskClass(Application.ExeName[1]) <> CDROMDisk then begin
    if not FileExists('c:\apcd.miw') then begin
      MessageDlg('Drive ' + Application.ExeName[1] + ' is not a CD-ROM drive. Arabic '+
                 'Playhouse only works when running off of a CD-ROM.',
                  mtError, [mbOk], 0);
      Exit;
    end;
  end else
    RunningOffCD := True;

  if (Screen.Fonts.IndexOf(strArabicFontName) = -1) or
     (Screen.Fonts.IndexOf('Kids') = -1) or
     (Screen.Fonts.IndexOf('Verdana') = -1) then begin
    if MessageDlg('The Arabic fonts that Arabic Playhouse needs have not been installed yet. '+
                  'If this is your first time running Playhouse, you should run Setup or install the fonts '+
                  'manually (from the Fonts folder on the CD). '+#10#13#10#13+
                  'Do you want to run Playhouse anyway?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;
  end;

  Application.Title := 'Arabic Playhouse';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TErrors, Errors);

  Application.Run;
end.
