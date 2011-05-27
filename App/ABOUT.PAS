unit About;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Banner, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    Banner1: TBanner;
    Panel3: TPanel;
    BitBtn1: TBitBtn;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses Main, MMSystem, MPlayer;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  MainForm.PlaySoundFile('ABOUT', True, Nil);
end;

procedure TAboutBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.StopAllSounds;
end;

end.
