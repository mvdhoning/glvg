program opengl_onewindow;

//compatibility for FPC
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

//for logs
{$APPTYPE CONSOLE}

uses
  //cmem,
  dglOpenGL, sysutils, SDL2, glvg, glvggui,classes;

const
  screenwidth: integer = 640;
  screenheight: integer = 480;

type
  TMyApplication = class(TglvgGuiWindow)
    public
      button1: TglvgGuiButton;
      connector1: TglvgGuiConnector;
      line1: TglvgGuiConnection;
      node1: TglvgGuiNode;
      node2: TglvgGuiNode;
      edit1: TglvgGuiEdit;
      edit2: TglvgGuiEdit;
      constructor Create(aowner: TComponent); override;
      destructor Destroy(); override;
      procedure OnClick(Sender:TObject);
      procedure OnDrag(Sender:TObject; x: single; y: single);
      procedure OnConnect(Sender: TComponent; Source: TObject);
  end;

var
  //needed for application itself
  window: PSDL_Window;
  context: TSDL_GLContext;
  running: Boolean;
  last_time,current_time, currentfps: integer;
  time_passed: glfloat;
  framecount: integer;

  //glvg
  text1: TglvgText; //debug text

  //my gui (application)
  myapp: TMyApplication;


constructor TMyApplication.Create();
begin
  setHeapTraceOutput('trace.log');
  inherited Create(nil);
  self.X:=50;
  self.Y:=10;
  self.Width:=screenwidth;
  self.Height:=screenheight;

//  GuiManager.Style := TglvgGroup.Create();
//  GuiManager.Style.AddElement(TglvgGroup.Create());
//  with GuiManager.Style.Element[GuiManager.Style.Count-1] as TglvgGroup do
//  begin
    //AddElement(TglvgRect.Create());
    (*
    with Element[Count-1] as TglvgRect do
    begin
      name:='sButton';
      Rx:=3.0;
      Ry:=3.0;
      Style.Color.SetColor(28,30,34,192);
      Style.FillType:=glvgSolid;
      init;
    end;  *)
//  end;

  button1 := TglvgguiButton.Create(self);
  button1.Name:='button1';
  button1.Caption.Text:='Test';
  button1.X:=400;
  button1.Y:=400;
  button1.Width:=200;
  button1.Height:=25;
  button1.Init;
  button1.OnClick:=self.onclick;

  connector1 := TglvgGuiConnector.Create(self);
  connector1.Name:='connector1';
  connector1.X:=300;
  connector1.Y:=300;
  connector1.OnDrag:=self.ondrag;
  connector1.Init;

  node1 := TglvgGuiNode.Create(self);
  node1.Name:='Node1';
  node1.X:=50;
  node1.Y:=250;
  node1.Width:=50+10;
  node1.Height:=50;
  node1.Init;
  node1.OnConnect:=self.onConnect;
  node1.OnDrag:=self.ondrag;

  node2 := TglvgGuiNode.Create(self);
  node2.Name:='Node2';
  node2.X:=150;
  node2.Y:=150;
  node2.Width:=50+10;
  node2.Height:=50;
  node2.Init;
  node2.OnConnect:=self.onConnect;
  node2.OnDrag:=self.ondrag;

  line1 := TglvgGuiConnection.Create(self);
  line1.X:=50;
  line1.Y:=50;
  line1.ToX:=connector1.X;
  line1.ToY:=connector1.Y;
  line1.Init;

  edit1 := TglvgGuiEdit.Create(self);
  edit1.Name:='edit1';
  edit1.X:=0;
  edit1.Y:=300;
  edit1.Width:=200;
  edit1.Height:=30;
  edit1.Init;
  edit1.Caption.Text:='Edit me';

  edit2 := TglvgGuiEdit.Create(self);
  edit2.Name:='edit2';
  edit2.X:=0;
  edit2.Y:=350;
  edit2.Width:=200;
  edit2.Height:=30;
  edit2.Init;
  edit2.Caption.Text:='Edit me too';

end;

destructor TMyApplication.Destroy;
var
  i: integer;
begin
  //List all component names on window
  for i:=0 to self.ComponentCount-1 do
  begin
    writeln(self.Components[i].Name);
  end;

  //Free Components
  FreeAndNil(line1);
  FreeAndNil(node1);
  FreeAndNil(node2);
  FreeAndNil(edit1);
  FreeAndNil(edit2);
  FreeAndNil(connector1);
  FreeAndNil(button1);

  inherited Destroy();

end;

procedure TMyApplication.OnConnect(Sender: TComponent; Source: TObject);
begin
  writeln('Connection from '+TComponent(Source).Name+ ' to '+Sender.Name);
  (Source as TglvgGuiConnector).ToNode:=(Sender as TglvgGuiNode);
end;

procedure TMyApplication.OnClick(Sender: TObject);
begin
  writeln((Sender as TglvgguiButton).Name); //Display the name of the button clicked
  writeln('Click! edit1:'+self.edit1.Caption.Text);
end;

procedure TMyApplication.OnDrag(Sender:TObject; x: single; y:single);
begin
  //writeln((Sender as TComponent).Name);

  if Sender is TglvgGuiConnector then
  begin
    self.line1.ToX:=X;
    self.line1.ToY:=Y;
    self.line1.Init;
    connector1.ToNode := nil;
  end;

  if Sender is TglvgGuiNode then
  begin
    if connector1.ToNode <> nil then
    begin
      connector1.X:=X;
      connector1.Y:=Y-5+connector1.ToNode.Height/2;
      self.line1.ToX:=connector1.ToNode.X;//-10+connector1.Width;
      self.line1.ToY:=connector1.ToNode.Y-5+connector1.ToNode.Height/2;
      self.line1.Init;
    end;
  end;

end;

procedure InitializeVariables;
begin
  //only for avoiding warnings
  window := nil;
  context := nil;
end;

//initializes SDL
function InitializeSDL: Boolean;
begin
  framecount:=0;
  time_passed:=0;
  current_time:=0;
  last_time:=0;
  Result := false;
  //only the video system is needed
  if SDL_Init(SDL_INIT_VIDEO) = 0 then
    Result := true;

  SDL_SetRelativeMouseMode(SDL_FALSE); //show the mouse cursor
end;

procedure InitializeOpenGL;
begin
  InitOpenGL;                   //core-functions
  ReadExtensions;               //Extensions
  ReadImplementationProperties; //Extension-Support-Bools
end;

procedure InitializeOpenGLVariables;
var
  i:integer;
begin

  glClearColor(0,0,0,0);
  //set current and last time correct just before rendering
  current_time := SDL_GetTicks();
  last_time:=current_time;

  //glvg
  text1 := TglvgText.Create();
  text1.Font.LoadFromFile('font.txt');
  text1.Font.Size:=12;
  text1.Text:='Hello World';
  text1.X:=10;
  text1.Y:=10;
  text1.Style.Color.SetColor(1,1,1,1);
  text1.Style.FillType:=glvgsolid;
  text1.Style.LineType:=glvgnone;
  text1.Init;

  //glvggui
  myapp := TMyApplication.Create(nil);

  for i:=0 to myapp.ComponentCount-1 do
  begin
    writeln(myapp.Components[i].Name);
  end;

  //Add a font and some text on the buton
  myapp.button1.Caption.Font.LoadFromFile('font.txt');
  myapp.edit1.Caption.Font.LoadFromFile('font.txt');
  myapp.edit2.Caption.Font.LoadFromFile('font.txt');
  myapp.button1.Caption.Text:='This is an test button.';
end;

procedure ResizeOpenGL(w,h: Integer);
begin
  if (h=0) then
     h:=1;
  glViewport(0, 0, w, h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(45.0,w/h,0.1,10000.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

//Event-Handler
procedure HandleEvents;
var
  event: TSDL_Event;
  mouseX,mouseY,mouseMoveX,mouseMoveY: integer;
  keymod: boolean;
begin
  while SDL_PollEvent(@event) > 0 do
  begin
    case event.type_ of
      SDL_QUITEV: //this only works with one window
        running := false; //stop main-loop

      //text input events

      //Special key input
      SDL_KEYDOWN:
        begin

          //detect ctrl key
          keymod:=(SDL_GetModState and KMOD_CTRL )>0;
          if keymod then writeln('ctrl');

          //exit application on escape key pressed
          if (event.key.keysym.scancode = SDL_SCANCODE_ESCAPE) then
          begin
            running := false;
          end;

          GuiManager.HandleKeyDown(event.key.keysym.sym, SDL_GetModState() );
        end;

      SDL_TEXTINPUT:
        begin
          GuiManager.HandleTextInputEvent(event.text.text);
        end;

      SDL_TEXTEDITING:
        begin
          writeln('textediting');
          (*
            Update the composition text.
            Update the cursor position.
            Update the selection length (if any).

          composition := event.edit.text;
          cursor := event.edit.start;
          selection_len := event.edit.length;
          *)
       end;

      //end tekst input events
      SDL_KEYUP:
        begin
        end;

      SDL_MOUSEMOTION:
        begin
          mouseMoveX := event.motion.xrel; //relative
          mouseMoveY := event.motion.yrel;
          mouseX := event.motion.x; //absolute
          mouseY := event.motion.y;
          text1.Text:='mouseX '+inttostr(mouseX)+' mouseY '+inttostr(mouseY);
          if GuiManager.LeftMouseClicked then text1.Text:=text1.Text+' pressed!';

          GuiManager.HandleMouseEvent(mousex, mousey, mousemovex, mousemovey, false, GuiManager.LeftMouseClicked, false);
        end;

      SDL_MOUSEBUTTONDOWN:
        begin
          if( event.button.button = SDL_BUTTON_LEFT ) then
            begin
              GuiManager.LeftMouseClicked:=true;
              GuiManager.HandleMouseEvent(event.button.x, event.button.y,0,0, true, false, false);
            end;
        end;

      SDL_MOUSEBUTTONUP:
        begin
          if( event.button.button = SDL_BUTTON_LEFT ) then
            begin
              GuiManager.LeftMouseClicked:=false;
              GuiManager.HandleMouseEvent(event.button.x, event.button.y,0,0, false, false, true);
            end;
        end;
		
    end;
  end;
end;

//update game logic pre render
procedure Update();
begin

  current_time := SDL_GetTicks();
  time_passed := (current_time - last_time) / 1000; //miliseconds to seconds

  if(time_passed >0) then
  begin
    //  calculate the number of frames per second
    currentfps := round(framecount / time_passed);

    //  Set time
    last_time := current_time;

    //  Reset frame count
    frameCount := 0;
  end;

  SDL_SetWindowTitle(window, pchar('OpenGL with SDL - '+inttostr(currentfps)+' fps'));

  //set current and last time correct just before rendering
  current_time := SDL_GetTicks();
  last_time:=current_time;
end;

//set 2d render mode
procedure Set2D();
begin
  glViewport(0, 0, screenwidth, screenheight);
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity();
  glOrtho (0, 640, 480, 0,-100,100);
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef (0.375, 0.375, 0.0);
end;

//set 3d render mode
procedure Set3D();
begin
  glEnable(GL_DEPTH_TEST);
  glViewport(0, 0, screenwidth, screenheight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(65.0, screenwidth / screenheight, 0.1, 60.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
end;

//Render
procedure Render;
begin
  framecount:=framecount+1;

  glEnable(GL_MULTISAMPLE);

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

  glMatrixMode (GL_PROJECTION); glLoadIdentity(); glOrtho (0, 640, 480, 0,-100,100);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  glDisable(GL_DEPTH_TEST);

  // Alpha Blending
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  //display gui
  myapp.Render;

  //display debug texts
  text1.Render;


  glFlush(); //for opengl to do its thing
  //sleep(0);
end;

begin

  DecimalSeparator := '.';

  InitializeVariables;
  try
    //initialize SDL
    if not InitializeSDL then
    begin
      WriteLn('Couldn''t initialize SDL!');
      Exit;
    end;

  //set opengl screen buffer attributes
  SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
  SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 1);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2 ); //force opengl version
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1 ); //force opengl version
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1); //doublebuffer

  //multisample aliasing
  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4);

  //create the window,
  //caption - first parameter
  //position: 100,100
  //640x480
  //OpenGL-Support
  window := SDL_CreateWindow('OpenGL with SDL - One Window Test', 100+400, 100, screenwidth, screenheight, SDL_WINDOW_OPENGL);

  //the opengl-context
  context := SDL_GL_CreateContext(window);

  //initialize OpenGL
  InitializeOpenGL;

  //initialize resources
  InitializeOpenGLVariables;

  SDL_GL_SetSwapInterval(0); //no vsync

  //main-loop
  running := true;
  GuiManager.LeftMouseClicked := false;

  while running do
    begin
      //Event-Handling
      HandleEvents;
      //Updating
      Update;
      //Rendering
      Render;
      //Swap-Window
      SDL_GL_SwapWindow(window);
    end;

  finally

  //free gui objects
  myapp.Free;
  //free debug text
  text1.Free;

  SDL_GL_DeleteContext(context);
  SDL_DestroyWindow(window);
  SDL_Quit;

end;

end.
