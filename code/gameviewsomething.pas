unit GameViewSomething;

interface

uses Classes,
  CastleVectors, CastleUIControls, CastleControls, CastleKeysMouse,
  CastleViewport, CastleScene, CastleTransform,
  CastleBehaviors, CastleSoundEngine;

type
  TViewSomething = class(TCastleView)
  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    MichalisViewport: TCastleViewport;
    LabelFps: TCastleLabel;
    BoxGoingUp: TCastleBox;
    DesignMouseWithHat1: TCastleTransformDesign;
    DesignMouseWithHat2: TCastleTransformDesign;
    DesignMouseWithHat3: TCastleTransformDesign;
    SoundSourceManual: TCastleSoundSource;
    SoundAlien: TCastleSound;
    MyButton, ButtonSave, ButtonLoad: TCastleButton;
  private
    procedure CollisionEnter(const CollisionDetails: TPhysicsCollisionDetails);
    procedure SaveGame(Sender: TObject);
    procedure LoadGame(Sender: TObject);
    procedure MyButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewSomething: TViewSomething;

implementation

uses CastleLog, CastleConfig;

constructor TViewSomething.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewsomething.castle-user-interface';
end;

procedure TViewSomething.Start;
begin
  inherited;
  { Executed once when view starts. }

  MyButton.Caption := 'Click me!';
  MyButton.OnClick := {$ifdef FPC}@{$endif} MyButtonClick;

  ButtonSave.OnClick := @SaveGame;
  ButtonLoad.OnClick := @LoadGame;
end;

procedure TViewSomething.Update(const SecondsPassed: Single; var HandleInput: boolean);
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil, 'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;
end;

procedure TViewSomething.MyButtonClick(Sender: TObject);
begin
  WritelnLog('Button clicked');

  // translation is 3D vector
  // TVector3

  BoxGoingUp.Translation := BoxGoingUp.Translation + Vector3(0, 1 , 0);
end;

function TViewSomething.Press(const Event: TInputPressRelease): Boolean;
var
  SphereWithStuff: TCastleTransform;
  Pos, Dir, Up: TVector3;
  Body: TCastleRigidBody;
begin
  Result := inherited;
  if Result then Exit;

  if Event.IsKey(keyP) then
  begin
    SoundSourceManual.Play(SoundAlien);
  end;

  if Event.IsKey(keyEnter) then
  begin
    { Executed when user presses space key. }
    WritelnLog('Space key pressed');

    //Sphere := TCastleSphere.Create(Self);
    //Sphere.Radius := 0.1;

    SphereWithStuff := TransformLoad('castle-data:/bullet.castle-transform', Self);

    MichalisViewport.Items.Add(SphereWithStuff);

    MichalisViewport.Camera.GetWorldView(Pos, Dir, Up);

    SphereWithStuff.Translation := Pos + Dir * 10.0;

    Body := SphereWithStuff.FindBehavior(TCastleRigidBody) as TCastleRigidBody;
    Body.LinearVelocity := Dir * 100.0;
    Body.OnCollisionEnter := @CollisionEnter;

    Result := true;
  end;
end;

procedure TViewSomething.CollisionEnter(const CollisionDetails: TPhysicsCollisionDetails);
begin
  { TODO: put enemies in a list (e.g. TCastleTransformList)
    to make this code less error-prone. }
  if CollisionDetails.OtherTransform = DesignMouseWithHat1 then
    DesignMouseWithHat1.Exists := false;
  if CollisionDetails.OtherTransform = DesignMouseWithHat2 then
    DesignMouseWithHat2.Exists := false;
  if CollisionDetails.OtherTransform = DesignMouseWithHat3 then
    DesignMouseWithHat3.Exists := false;
end;

procedure TViewSomething.SaveGame(Sender: TObject);
var
  Pos, Dir, Up: TVector3;
begin
  MichalisViewport.Camera.GetWorldView(Pos, Dir, Up);

  UserConfig.SetVector3('player_position', Pos);
  UserConfig.SetVector3('player_direction', Dir);
  UserConfig.SetVector3('player_up', Up);
  UserConfig.SetValue('player_saved', true);

  UserConfig.Save;
end;

procedure TViewSomething.LoadGame(Sender: TObject);
var
  Pos, Dir, Up: TVector3;
begin
  UserConfig.Load;

  if UserConfig.GetValue('player_saved', false) then
  begin
    Pos := UserConfig.GetVector3('player_position');
    Dir := UserConfig.GetVector3('player_direction');
    Up := UserConfig.GetVector3('player_up');

    MichalisViewport.Camera.SetWorldView(Pos, Dir, Up);
  end;
end;

end.
