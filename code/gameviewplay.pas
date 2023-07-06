{ Main "playing game" view, where most of the game logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
unit GameViewPlay;

interface

uses Classes,
  CastleComponentSerialize, CastleUIControls, CastleControls,
  CastleKeysMouse, CastleViewport, CastleScene, CastleVectors, CastleCameras,
  CastleTransform,
  GameEnemy;

type
  { Main "playing game" view, where most of the game logic takes place. }
  TViewPlay = class(TCastleView)
  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    LabelFps: TCastleLabel;
    MainViewport: TCastleViewport;
    WalkNavigation: TCastleWalkNavigation;
    SceneEnemy1, SceneEnemy2, SceneEnemy3, SceneEnemy4: TCastleScene;
    MyButton: TCastleButton;
    Box1: TCastleBox;
  private
    { Enemies behaviors }
    Enemies: TEnemyList;
    procedure MyButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Stop; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewPlay: TViewPlay;

implementation

uses SysUtils, Math,
  CastleSoundEngine, CastleLog, CastleStringUtils, CastleFilesUtils,
  GameViewMenu, GameSound;

{ TViewPlay ----------------------------------------------------------------- }

constructor TViewPlay.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewplay.castle-user-interface';
end;

procedure TViewPlay.Start;

  procedure InitializeEnemy(const SceneEnemy: TCastleScene);
  var
    Enemy: TEnemy;
  begin
    { Below using nil as Owner of TEnemy, as the Enemies list already "owns"
      instances of this class, i.e. it will free them. }
    Enemy := TEnemy.Create(nil);
    SceneEnemy.AddBehavior(Enemy);
    Enemies.Add(Enemy);
  end;

begin
  inherited;

  { Create TEnemy instances, add them to Enemies list }
  Enemies := TEnemyList.Create(true);
  InitializeEnemy(SceneEnemy1);
  InitializeEnemy(SceneEnemy2);
  InitializeEnemy(SceneEnemy3);
  InitializeEnemy(SceneEnemy4);

  MyButton.Caption := 'Click me!';
  // ObjFpc synytax in FPC
  //MyButton.OnClick := {$ifdef FPC}@{$endif} MyButtonClick;

  // FPC people:
  MyButton.OnClick := @MyButtonClick;

  // Delphi people:
  //MyButton.OnClick := MyButtonClick;
end;

procedure TViewPlay.Stop;
begin
  FreeAndNil(Enemies);
  inherited;
end;

procedure TViewPlay.Update(const SecondsPassed: Single; var HandleInput: Boolean);
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil, 'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;
end;

function TViewPlay.Press(const Event: TInputPressRelease): Boolean;
var
  HitEnemy: TEnemy;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TViewPlay.Press method should be used to handle keys
    not handled in children controls.
  }

  if Event.IsMouseButton(buttonLeft) then
  begin
  end;
end;

procedure TViewPlay.MyButtonClick(Sender: TObject);
begin
  WritelnLog('Button clicked');

  // on 2nd or 3rd part:
  //SoundEngine.Sound(SoundButtonClick);

  // transltion is 3D vector
  // TVector3

  Box1.Translation := Box1.Translation + Vector3(0, 1 , 0);
end;

end.
