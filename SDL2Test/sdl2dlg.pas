program opengl_onewindow;

//compatibility for FPC
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

//for logs
{$APPTYPE CONSOLE}

uses
  //cmem,
  dglOpenGL, sysutils, SDL2, glvg, caticon;

const
  screenwidth: integer = 640;
  screenheight: integer = 480;

var
  //needed for application itself
  window: PSDL_Window;
  context: TSDL_GLContext;
  running: Boolean;
  last_time,current_time, currentfps: integer;
  time_passed: glfloat;
  framecount: integer;
  //glvg
  polystar: TglvgPolygon; //TPolygonShape;
  polyrect: TglvgRect;
  //bg1: TglvgRect;
  polycirc: TglvgElipse;
  polytext: TglvgText;

  scissor1: TglvgRect;
  scissor2: TglvgRect;

  test1, test2, test3: TglvgRect;
  hc1: single;
  up: boolean;

  grouptest: TglvgGroup;

  testTransform : TTransform;

  //arc1: TglvgPolygon;

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

  SDL_SetRelativeMouseMode(SDL_FALSE); //show mouse
end;

procedure InitializeOpenGL;
begin
  InitOpenGL;                   //core-functions
  ReadExtensions;               //Extensions
  ReadImplementationProperties; //Extension-Support-Bools
end;

procedure InitializeOpenGLVariables;
var
  mypath: string;
begin

  glClearColor(0,0,0,0);
  //set current and last time correct just before rendering
  current_time := SDL_GetTicks();
  last_time:=current_time;
     (*
  //glvg
  bg1 := TglvgRect.Create;
  bg1.X:=100;
  bg1.Y:=300;
  bg1.Width:=300;
  bg1.Height:=100;
  bg1.Style.Color.SetColor(0,1,0,1);
  bg1.Style.Pattern.Width:=10;
  bg1.Style.Pattern.Height:=10;

  bg1.Style.Pattern.AddElement(TglvgRect.Create);
  TglvgRect(bg1.Style.Pattern.Element[0]).Polygon.id := 3;
  TglvgRect(bg1.Style.Pattern.Element[0]).x := 0;
  TglvgRect(bg1.Style.Pattern.Element[0]).y := 0;
  TglvgRect(bg1.Style.Pattern.Element[0]).width := 10;
  TglvgRect(bg1.Style.Pattern.Element[0]).height := 10;
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.Color.SetColor(1,1,1,0.9);
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.FillType := glvgSolid;
  TglvgRect(bg1.Style.Pattern.Element[0]).Style.LineType := glvgNone;
  TglvgRect(bg1.Style.Pattern.Element[0]).Init;
  TglvgRect(bg1.Style.Pattern.Element[0]).Polygon.Tesselate;

  bg1.Style.Pattern.AddElement(TglvgRect.Create);
  TglvgRect(bg1.Style.Pattern.Element[1]).Polygon.id := 1;
  TglvgRect(bg1.Style.Pattern.Element[1]).x := 0;
  TglvgRect(bg1.Style.Pattern.Element[1]).y := 0;
  TglvgRect(bg1.Style.Pattern.Element[1]).width := 5;
  TglvgRect(bg1.Style.Pattern.Element[1]).height := 5;
  TglvgRect(bg1.Style.Pattern.Element[1]).Style.Color.SetColor('#add8e6');
  TglvgRect(bg1.Style.Pattern.Element[1]).Style.FillType := glvgSolid;
  TglvgRect(bg1.Style.Pattern.Element[1]).Style.LineType := glvgNone;
  TglvgRect(bg1.Style.Pattern.Element[1]).Init;
  TglvgRect(bg1.Style.Pattern.Element[1]).Polygon.Tesselate;

  bg1.Style.Pattern.AddElement(TglvgRect.Create);
  TglvgRect(bg1.Style.Pattern.Element[2]).Polygon.id := 2;
  TglvgRect(bg1.Style.Pattern.Element[2]).x := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).y := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).width := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).height := 5;
  TglvgRect(bg1.Style.Pattern.Element[2]).Style.Color.SetColor('#add8e6');
  TglvgRect(bg1.Style.Pattern.Element[2]).Style.FillType := glvgSolid;
  TglvgRect(bg1.Style.Pattern.Element[2]).Style.LineType := glvgNone;
  TglvgRect(bg1.Style.Pattern.Element[2]).Init;
  TglvgRect(bg1.Style.Pattern.Element[2]).Polygon.Tesselate;

  bg1.Style.FillType := glvgpattern;
  bg1.Style.LineType := glvgNone;
  bg1.Polygon.Id := 10;
  bg1.Init;
   *)


  //PATHPOLYGON TEST
  polystar := TglvgPolygon.Create();
  polystar.Style.Color.SetColor(1,1,0,1);     //first set color etc
  polystar.Style.LineWidth := 1.0;
  polystar.Style.LineColor.SetColor(1,0,1,1);
  polystar.Style.FillType:=glvgNone;//glvgsolid;

  //mypath := 'M100,200 C100,100 250,100 250,200 S400,300 400,200';
  //mypath := 'M 25,100 C 25,150 75,150 75,100 S 100,25 150,75';
  //mypath := 'M16,0 c 0,0 –16,24 –16,33 c 0,9 7,15 16,15 c 9,0 16,–7 16,–15 c 0,–9 –16,–33 –16,–33';

  //mypath := 'M 100,100 C 220,100 250,120 250,150'; //absolute
  //mypath := 'M 100,100 c 120,0 150,20 150,50 c 120,0 150,20 150,50';       //relative

  //mypath := 'M100,200 C100,100 400,100 400,200 c100,200 400,100 300,0';
  //mypath := 'M100,200 C100,100 400,100 400,200 s100,100 300,0';

  //mypath := 'M 150.316,161.805 C 163.998,176.83 192.441,188.11 198.279,186.679 C 203.021,185.538 202.283,146.414 198.481,124.025 C 182.321,150.822 150.316,161.805 150.316,161.805';


  //mypath := 'M100,200 C100,100 400,100 400,200';

  //mypath := 'M365,563 L 183,-33 L 0,563 H 101 L 183, 296 L 270, 563 H365 Z';
//  mypath := 'M35,1 H 18 V 564 H 355 V 420 H 125 V 144 H 248 V 211 H 156 V 355 H 355 V 1 Z';

  //mypath := 'M150 0 L75 200 L225 200 Z'; //Simple Triangle

  //mypath := 'M 190 328 L 190 328 L 475 328 L 475 328 L 475 505 Q 475 505 475 551.390625 469.109375 566.109375 Q 469.109375 566.109375 464.5625 577.265625 450.046875 585.296875 Q 450.046875 585.296875 430.546875 596 408.765625 596 L 408.765625 596 L 387 596 L 387 596 L 387 613 L 387 613 L 650 613 L 650 613 L 650 596 L 650 596 L 628.234375 596 Q 628.234375 596 606.453125 596 586.953125 585.734375 Q 586.953125 585.734375 572.4375 578.609375 567.21875 564.109375 Q 567.21875 564.109375 562 549.609375 562 505 L 562 505 L 562 108 Q 562 108 562 61.828125 567.890625 47.03125 Q 567.890625 47.03125 572.4375 35.828125 586.5 27.765625 Q 586.5 27.765625 606.453125 17 628.234375 17 L 628.234375 17 L 650 17 L 650 17 L 650 0 L 650 0 L 387 0 L 387 0 L 387 17 L 387 17 L 408.765625 17 Q 408.765625 17 446.421875 17 463.65625 38.96875 Q 463.65625 38.96875 475 53.3125 475 108 L 475 108 L 475 295 L 475 295 L 190 295 L 190 295 L 190 108 Q 190 108 190 61.828125 195.859375 47.03125 Q 195.859375 47.03125 200.375 35.828125 214.828125 27.765625 Q 214.828125 27.765625 234.21875 17 255.890625 17 L 255.890625 17 L 278 17 L 278 17 L 278 0 L 278 0 L 15 0 L 15 0 L 15 17 L 15 17 L 36.765625 17 Q 36.765625 17 74.875 17 92.109375 38.96875 Q 92.109375 38.96875 103 53.3125 103 108 L 103 108 L 103 505 Q 103 505 103 551.390625 97.109375 566.109375 Q 97.109375 566.109375 92.5625 577.265625 78.5 585.296875 Q 78.5 585.296875 58.546875 596 36.765625 596 L 36.765625 596 L 15 596 L 15 596 L 15 613 L 15 613 L 278 613 L 278 613 L 278 596 L 278 596 L 255.890625 596 Q 255.890625 596 234.21875 596 214.828125 585.734375 Q 214.828125 585.734375 200.828125 578.609375 195.4140625 564.109375 Q 195.4140625 564.109375 190 549.609375 190 505 L 190 505 Z';

  //mypath:='M50,50 A30,50 0 0,1 100,100'; //arc0

  //mypath:='M40,20 A30,30 0 0,0 70,70'; //arc1
  //mypath:='M40,20  A30,30 0 1,0 70,70'; //arc2
  //mypath:='M40,20  A30,30 0 1,1 70,70'; //arc3
  //mypath:='M40,20  A30,30 0 0,1 70,70'; //arc4

  //https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
  mypath:='M10 315 L 110 215 A 30 50 0 0 1 162.55 162.45 L 172.55 152.45 A 30 50 -45 0 1 215.1 109.9 L 315 10';// TODO bugged does not draw 2nd arc correct xrot is not handled correctly
  //mypath:='M10 315 L 172.55 152.45 A 30 50 -45 0 1 215.1 109.9 L 315 10'; //xrot -45 does bug
  //http://xahlee.info/js/svg_path_ellipse_arc.html
  //mypath:='M 0 50 L 10 50 A 30 20, 30, 0 0, 90 50 L 100 50';  //'M 0 50 L 10 50 A 3 2, 30, 0 0, 90 50 L 100 50'
  //mypath:='M 10 315 L 20 215 A 30 50, 0, 0 1, 162 162 L 182 162'; //lines do not touch?

  //TODO svg scales the radius*2 to match distance between start and end point
  //https://jsfiddle.net/rxf7j0px/ test case
  //https://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes F62
  //If rx, ry and (mod360) are such that there is no solution (basically, the ellipse is not big enough to reach from (x1, y1) to (x2, y2)) then the ellipse is scaled up uniformly until there is exactly one solution
  //(until the ellipse is just big enough)

  //mypath:='M80 80 A 45 45, 0, 0, 0, 125 125 L 125 80 Z'; //arc4
  //mypath:='M230 80 A 45 45, 0, 1, 0, 275 125 L 275 80 Z'; //arc4
  //mypath:='M80 230 A 45 45, 0, 0, 1, 125 275 L 125 230 Z'; //arc4
  //mypath:='M230 230 A 45 45, 0, 1, 1, 275 275 L 275 230 Z'; //arc4

  polystar.Polygon.Path := mypath;

  //polystar.Style.GradColorAngle:=90;
  //polystar.Style.NumGradColors := 2;
  //polystar.Style.GradColor[0].a :=1.0;
  //polystar.Style.GradColor[0].SetColor('#FF0000');
  //polystar.Style.GradColor[0].x:=10;
  //polystar.Style.GradColor[1].SetColor('#00FF00');
  //polystar.Style.GradColor[1].x:=200;
  //polystar.Style.FillType := glvgLinearGradient;

  polystar.Polygon.Id:=6;
  //polystar.Polygon.Tesselate(); //manualy call tesselate
  polystar.Init;


  //next shape
  polyrect := TglvgRect.Create;
  polyrect.X:= 10.0;
  polyrect.Y:= 10.0;
  polyrect.Width:=100.0;
  polyrect.Height:=200.0;
  polyrect.Rx:=20.0;
  polyrect.Ry:=20.0; //Optional
  polyrect.Style.Color.SetColor(1,1,0,0.6);
  //writeln('Rectangle');
  //polyrect.Init;
  //polyrect.Polygon.Tesselate();

  polyrect.Style.GradColorAngle:=90;
  //polyrect.Style.GradColorAngleAlpha:=0;
  polyrect.Style.NumGradColors := 2;
  polyrect.Style.GradColor[0].a :=1.0;
  //polyrect.Style.GradColor[1].a :=1.0;

  polyrect.Style.GradColor[0].SetColor('#FF0000');
  polyrect.Style.GradColor[0].x:=10;
  polyrect.Style.GradColor[1].SetColor('#00FF00');
  polyrect.Style.GradColor[1].x:=100;

  polyrect.Style.FillType := glvgLinearGradient;
  polyrect.Style.LineType := glvgSolid;
  polyrect.Polygon.Id:=7;
  //polyrect.Style.Color.a:=0.5;
  polyrect.Init;
  polyrect.Style.LineType := glvgSolid;

  polycirc := TglvgElipse.Create();
  //polycirc.Transform:=TTransform.Create('rotate(-45)');
  polycirc.X:=172.55+(215.1-172.55)/2; //110+(162.55 - 110)/2;
  polycirc.Y:=152.45+(109.9-152.45)/2;//215+(162.45-215)/2;
  polycirc.Rx:=30;
  polycirc.Ry:=50;
  polycirc.Style.Color.SetColor(1,0,0,0.5);
  polycirc.Style.FillType:=glvgsolid;

  polycirc.Init;


  //vector font
  polytext := TglvgText.Create;
  polytext.X := 100;
  polytext.Y := 100;
  polytext.Style.Color.SetColor(1,0,0,1);
  polytext.Style.LineColor.SetColor(1,0,1,1);

  polytext.Style.NumGradColors:=2;
  with polytext.Style.GradColor[0] do
  begin
    r:=1.0; //yellow
    g:=1.0;
    b:=0.0;
    x:=0;
  end;


  with polytext.Style.GradColor[1] do
  begin
    r:=0.0; //blue
    g:=0.0;
    b:=1.0;
    x:=1000;
  end;


  polytext.Style.GradColorAngle:=90; //90

  polytext.Style.FillType := glvgSolid; //glvgLinearGradient;
  polytext.Style.LineType := glvgNone; //glvgSolid;

  polytext.Font.Size := 32; //12; //12pt
  polytext.Font.LoadFromFile('font.txt');
  //polytext.Font.Scale := 0.05; //TODO: Should be related to font-size?
  polytext.Text := 'Hello World!';
  polytext.Style.LineWidth:=2.0;


  //scissor
  scissor1 := TglvgRect.Create;
  scissor1.X:= 10.0;
  scissor1.Y:= 20.0;
  scissor1.Width:=200.0;
  scissor1.Height:=400.0;
  scissor1.Style.FillType:=glvgSolid;
  scissor1.Style.LineType := glvgNone;
  scissor1.Init();
  hc1:=scissor1.y;

  scissor2 := TglvgRect.Create;
  scissor2.X:= 220.0;
  scissor2.Y:= 20.0;
  scissor2.Width:=200.0;
  scissor2.Height:=400.0;
  scissor2.Style.FillType:=glvgSolid;
  scissor2.Style.LineType := glvgNone;
  scissor2.Init();

  //test shapes
  test1 := TglvgRect.Create;
  test1.X:= 10.0;
  test1.Y:= 10.0;
  test1.Width:=100.0;
  test1.Height:=100.0;
  test1.Rx:=20.0;
  test1.Ry:=20.0; //Optional
  test1.Style.Color.SetColor(1,1,0,0.6);
  test1.Style.GradColorAngle:=90;
  test1.Style.NumGradColors := 2;
  test1.Style.GradColor[0].a :=1.0;
  test1.Style.GradColor[0].SetColor('#FF0000');
  test1.Style.GradColor[0].x:=10;
  test1.Style.GradColor[1].SetColor('#00FF00');
  test1.Style.GradColor[1].x:=100;
  test1.Style.FillType := glvgLinearGradient;
  test1.Style.LineType := glvgSolid;
  test1.Init;

  test2 := TglvgRect.Create;
  test2.X:= 120.0;
  test2.Y:= 10.0;
  test2.Width:=100.0;
  test2.Height:=100.0;
  test2.Rx:=20.0;
  test2.Ry:=20.0; //Optional
  test2.Style.Color.SetColor(1,1,0,0.6);
  test2.Style.GradColorAngle:=90;
  test2.Style.NumGradColors := 2;
  test2.Style.GradColor[0].a :=1.0;
  test2.Style.GradColor[0].SetColor('#FF0000');
  test2.Style.GradColor[0].x:=10+test2.x; //adjust color start coord according to x pos of shape
  test2.Style.GradColor[1].SetColor('#00FF00');
  test2.Style.GradColor[1].x:=100+test2.x;;
  test2.Style.FillType := glvgLinearGradient;
  test2.Style.LineType := glvgSolid;
  test2.Init;


  test3 := TglvgRect.Create;
  test3.X:= 10.0;
  test3.Y:= 120.0;
  test3.Width:=100.0;
  test3.Height:=100.0;
  test3.Rx:=20.0;
  test3.Ry:=20.0; //Optional
  test3.Style.Color.SetColor(1,1,0,0.6);
  test3.Style.GradColorAngle:=90;
  test3.Style.NumGradColors := 2;
  test3.Style.GradColor[0].a :=1.0;
  test3.Style.GradColor[0].SetColor('#FF0000');
  test3.Style.GradColor[0].x:=10;
  test3.Style.GradColor[1].SetColor('#00FF00');
  test3.Style.GradColor[1].x:=100;
  test3.Style.FillType := glvgLinearGradient;
  test3.Style.LineType := glvgSolid;
  test3.Init;
  up:=false;


  grouptest:=TglvgGroup.Create();
  grouptest.id:=2;
  grouptest.ClipPath:=TglvgGroup.Create();//scissor2;
  grouptest.ClipPath.AddElement(scissor2);
  grouptest.AddElement(polystar);

  loadcat();


  testTransform := TTransform.Create();
  //testTransform.Text:='translate(100.0,20) scale(1,2,3)';
  //testTransform.Text:='skewX(-30)';
  testTransform.Text:='rotate(-45,'+floattostr(polycirc.x)+','+floattostr(polycirc.y)+')';//rotate debug circle;
  //testTransform.Text:='rotate(-45,0,0)';//rotate debug circle;
  testTransform.Parse();

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
  dx,dy: integer;
begin
  while SDL_PollEvent(@event) > 0 do
  begin
    case event.type_ of
      SDL_QUITEV: //this only works with one window
        //stop main-loop
        running := false;
      
	  SDL_KEYDOWN:
        begin
        if (event.key.keysym.scancode = SDL_SCANCODE_ESCAPE) then
          begin
            running := false;
          end;
        end;

      SDL_KEYUP:
        begin
        end;

      SDL_MOUSEMOTION:
        begin
          dx := event.motion.xrel;
          dy := event.motion.yrel;
        end;

      SDL_MOUSEBUTTONDOWN:
        begin
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
var
  //MVMat    : TGLMatrixd4;
  //p1,p2,rhs : TPolygonPoint;
  x,y,w,h: integer;
  pid,cid: integer;
  i,a,b,c,d:integer;
  parentmask:integer;
  childmask:integer;

begin


  framecount:=framecount+1;

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

  glMatrixMode (GL_PROJECTION); glLoadIdentity(); glOrtho (0, 640, 480, 0,-100,100);
  glMatrixMode (GL_MODELVIEW); glLoadIdentity(); glTranslatef (0.375, 0.375, 0.0);

  glDisable(GL_DEPTH_TEST);

  //AntiAlias
  //glEnable (GL_BLEND);
  //glEnable (GL_POLYGON_SMOOTH); //makes triangle faces show up
  //glDisable (GL_DEPTH_TEST);

  // Alpha Blending
  glEnable (GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

   (*
  //begin scissor via stencil poc
  //parentmask:=12;
  //childmask:=14;


  a:=0;
  b:=0;
  c:=1;
  d:=0;
  //pid := (A shl 24) + (B shl 16) + (C shl 8) + D;
  pid := (C shl 4) + D;

  a:=0;
  b:=0;
  c:=255;
  d:=0;
  //parentmask := (A shl 24) + (B shl 16) + (C shl 8) + D;
  parentmask := (C shl 4) + D;

  a:=0;
  b:=0;
  c:=255;
  d:=255;
  //childmask := (A shl 24) + (B shl 16) + (C shl 8) + D;
  childmask := (C shl 4) + D;

  //sid:=4;
  //sid:=0 or (1 shl 7{3})+1;
  //writeln(pid);
  //smk:=sid or (1 shl 7{3}); //set bit 8 to value so almost al other values are a child of this
  //smk:=parentmask;


  scissor1.Polygon.id:=pid;
  scissor1.Polygon.Mask:=parentmask;
  a:=0;
  b:=0;
  c:=1;
  d:=1;
  cid := (C shl 4) + D;
  test1.Polygon.Id:=cid;
  a:=0;
  b:=0;
  c:=1;
  d:=2;
  cid := (C shl 4) + D;
  test2.Polygon.Id:=cid;
  a:=0;
  b:=0;
  c:=1;
  d:=3;
  cid := (C shl 4) + D;
  test3.Polygon.Id:=cid;
  //a:=0;
  //b:=0;
  //c:=1;
  //d:=4;
  //cid := (C shl 4) + D;
  //polystar.Polygon.Id:=cid;
  //polystar.Polygon.Mask:=childmask;
  test1.Polygon.Mask:=childmask;
  test2.Polygon.Mask:=childmask;
  test3.Polygon.Mask:=childmask;

  //scissor1.Render;

  //writeln(smk);
  glColorMask(FALSE, FALSE, FALSE, FALSE);

  //enable stencil buffer
  glEnable(GL_STENCIL_TEST);

  //write a one to the stencil buffer everywhere we are about to draw
  glStencilFunc(GL_ALWAYS, pid, parentmask);

  //this is to always pass a one to the stencil buffer where we draw
  glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

  //render scissor
  scissor1.Polygon.Render();//Stencil();

  //until stencil test is diabled, only write to areas where the
  //stencil buffer has a one. This fills the shape
  glStencilFunc(GL_EQUAL, pid, parentmask);

  // don't modify the contents of the stencil buffer
  glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

  //draw colors again
  glColorMask(TRUE,TRUE, TRUE, TRUE);

  //draw contents
  glPushMatrix();
    glTranslateF(scissor1.Y,hc1,0);
    test1.Polygon.render(pid,parentmask);
    test1.Polygon.renderPath();
    test2.Polygon.render(pid,parentmask);
    test2.Polygon.renderPath();
    //test2.Polygon.RenderBoundingBox();
    test3.Polygon.render(pid,parentmask);
    test3.Polygon.renderPath();
    //polystar.Polygon.Render(pid,parentmask);
    //polystar.Polygon.render;
    //polystar.Polygon.RenderPath();
  glPopMatrix();
  if up then
     hc1:=hc1+0.01
  else
     hc1:=hc1-0.01;
  if hc1<=0 then up:=true;
  if hc1>=scissor1.y+scissor1.Height-10 then up:=false;
  //polystar.Polygon.Render(sid,smk);
  //polystar.Polygon.RenderPath();

  //'default' rendering again
  glColorMask(TRUE,TRUE, TRUE, TRUE);
  glDisable(GL_STENCIL_TEST);
  *)

  //glClear(GL_STENCIL_BUFFER_BIT); //quick fix

  //end scissor via stencil poc


  //begin scissor via stencil poc
  (*

  //sid:=0 or (1 shl 8{3})+1;
  //writeln(sid);
  //smk:=sid or (1 shl 8{3}); //set bit 8 to value so almost al other values are a child of this
  a:=0;
  b:=0;
  c:=2;
  d:=0;
  //pid := (A shl 24) + (B shl 16) + (C shl 8) + D;
  pid := (C shl 4) + D;
  scissor2.Polygon.id:=pid;
  scissor2.Polygon.Mask:=parentmask;

  a:=0;
  b:=0;
  c:=2;
  d:=1;
  cid := (C shl 4) + D;
  polystar.Polygon.Id:=cid;
  polystar.Polygon.Mask:=childmask;
   //scissor2.Polygon.RenderStencil();
  //writeln(smk);
  glColorMask(FALSE, FALSE, FALSE, FALSE);

  //enable stencil buffer
  glEnable(GL_STENCIL_TEST);

  //write a one to the stencil buffer everywhere we are about to draw
  glStencilFunc(GL_ALWAYS, pid, parentmask);

  //this is to always pass a one to the stencil buffer where we draw
  glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

  //render scissor
  scissor2.Polygon.Render();

  //until stencil test is diabled, only write to areas where the
  //stencil buffer has a one. This fills the shape
  glStencilFunc(GL_EQUAL, pid, parentmask);

  // don't modify the contents of the stencil buffer
  glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

  //draw colors again
  glColorMask(TRUE,TRUE, TRUE, TRUE);

  //draw shape
  polystar.Polygon.Render(pid,parentmask);
  polystar.Polygon.RenderPath();

  //'default' rendering again
  glColorMask(TRUE,TRUE, TRUE, TRUE);
  glDisable(GL_STENCIL_TEST);

//  glClear(GL_STENCIL_BUFFER_BIT); //quick fix
  *)

  //grouptest.render;
  //end scissor via stencil poc

  //writeln(polyrect.Polygon.id);

  //polyrect.render;
  //writeln(floattostr(polyrect.Polygon.Points[80].y));

  //polycirc.Render; //renders a square fill?


  //render text with vector font
  //AntiAlias
  //glPolygonMode( GL_FRONT, GL_FILL ) ;
  //glEnable (GL_POLYGON_SMOOTH);
  //glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST ) ;
 // polytext.Render;
  //glDisable (GL_POLYGON_SMOOTH);

  //polystar.render();
  //glDisable(GL_MULTISAMPLE); //smooth shape by antialias by multisample

  (*
  cat.Render();
  //glDisable(GL_MULTISAMPLE);

  testTransform.Apply();
  polytext.Render;
  *)


  glpushmatrix();
    testTransform.Apply();
    polycirc.Render();
  glpopmatrix();

  polystar.Render();


  glFlush(); //for opengl to do its thing

end;



begin
  setHeapTraceOutput('trace.log');
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

  //antialias by multisample
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

  Writeln('cleanup grouptest');
  FreeAndNil(grouptest);
  //FreeAndNil(polystar); //free called in grouptest free
  //FreeAndNil(scissor2); //free called in grouptest free

  FreeAndNil(polyrect);
  writeln('cleanup polycirc');
  FreeAndNil(polycirc);
  //bg1.Free;
  FreeAndNil(polytext);

  FreeAndNil(test1);
  FreeAndNil(test2);
  FreeAndNil(test3);

  FreeAndNil(cat);

  FreeAndNil(scissor1);


  writeln('cleanup testtransfrom');
  testTransform.Free;
  //arc1.Free;



  writeln('cleanup SDL');
  readln();
  SDL_GL_DeleteContext(context);
  SDL_DestroyWindow(window);
  SDL_Quit;


end;

end.
