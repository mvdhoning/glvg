unit glvggui;

(* Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the glvggui main unit.
 *
 * The Initial Developer of the Original Code is
 * M van der Honing.
 * Portions created by the Initial Developer are Copyright (C) 2002-2004
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 *  M van der Honing
 *
 *)

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses glvg, types, classes,sysutils;

type
//Experimental idea for making a vector gui ... (or group control)

TOnClickEvent = procedure() of Object;
TOnDragEvent = procedure(x: single; y: single) of Object;

TglvgGuiControl = class(TComponent)
private
  FElements: TglvgGroup;
  FMouseOver: boolean;
  FX: single;
  FY: single;
  FWidth: single;
  FHeight: single;
  fonClick : TonClickEvent;
  fonDrag : TonDragEvent;
  fDraggAble : boolean;
  fIsDragged : boolean;

public
  Constructor Create(aowner:TComponent); override;

  procedure Render; virtual;

  procedure MouseDrag; virtual;
  procedure MouseOver; virtual;
  procedure MouseIn; virtual;
  procedure MouseOut; virtual;
  procedure Click; virtual;

  procedure HandleMouseEvent(mousex: integer; mousey: integer; mousemovex: integer; mousemovey: integer; leftclick: boolean; dragclick: boolean);
  property Elements: TglvgGroup read fElements write fElements;

published
  property X: single read Fx write Fx;
  property Y: single read Fy write Fy;
  property Width: single read FWidth write FWidth;
  property Height: single read FHeight write FHeight;
  property OnClick: TonClickEvent read fonClick write fonClick;
  property OnDrag: TonDragEvent read fonDrag write fonDrag;
  property DraggAble: boolean read fDraggAble write fDraggAble;
end;

TglvgGuiWindow = class ( TglvgGuiControl )
public
  Constructor Create(aowner:Tcomponent); override;
end;

TglvgGuiConnector = class ( TglvgGuiControl )
public
  Constructor Create(aowner:Tcomponent); override;
  procedure Init;
  procedure MouseIn; override;
  procedure MouseOut; override;
end;

TglvgGuiConnection = class ( TglvgGuiControl )
private
  fToX: single;
  fToY: single;
public
  Constructor Create(aowner:Tcomponent); override;
  procedure Init;
  procedure MouseIn; override;
  procedure MouseOut; override;
published
  property ToX: single read fToX write fTox;
  property ToY: single read fToY write fToY;
end;

TglvgGuiNode = class ( TglvgGuiControl )
private
  fBackGround: TglvgGuiWindow;
  fFrom: TglvgGuiConnector;
  fTo: TglvgGuiConnector;
public
  Constructor Create(aowner:Tcomponent); override;
  procedure Init;
  procedure Render; override;
end;

TglvgGuiButton = class ( TglvgGuiControl )
private
  fdrawtext : TglvgText;
public
  Constructor Create(aowner:Tcomponent); override;
  Destructor Destroy; override;
  procedure Init;
  procedure MouseIn; override;
  procedure MouseOut; override;
  procedure Click; override;
  procedure Render; override;
published
  property Caption: TglvgText read Fdrawtext write Fdrawtext;
end;

TglvgGuiGridDrawState = set of (gdSelected, gdFocused, gdFixed);

TglvgGuiGrid = class ( TglvgGuiControl )
private
 FCells: array of array of String;
 FColCount: integer;
 FRowCount: integer;
 function GetCell(x: integer; y:integer): string;
 procedure SetCell(x: integer; y:integer; value: string);
 procedure SetRowCount(value: integer);
 procedure SetColCount(value: integer);
public
 procedure DrawCell(ACol: Longint; ARow: Longint; ARect: TRect; AState: TglvgGuiGridDrawState); virtual; abstract;
 property Cells[x:integer;y:integer]:string read GetCell write SetCell;
 property RowCount: integer read FRowCount write SetRowCount;
 property ColCount: integer read FColCount write SetColCount;
end;

implementation

uses dglopengl;

  //TglvgGuiControl

  constructor TglvgGuiControl.Create(aowner: TComponent);
  begin
    inherited Create(aowner);
    fElements := TglvgGroup.Create();
    fIsDragged := false;
  end;

  procedure TglvgGuiControl.Render;
  var
    i: integer;
  begin
    glpushmatrix();
      gltranslatef(Fx,Fy,0);
      for i:=0 to self.Elements.Count-1 do
      begin
        self.Elements.Element[i].Render;
        //self.Elements.Element[i].Polygon.RenderBoundingBox();
      end;
    glpopmatrix();
  end;

  procedure TglvgGuiControl.MouseOver;
  begin
  end;

  procedure TglvgGuiControl.MouseDrag;
  begin
    //handle mousedrag
    if Assigned(FOnDrag) then
      FOnDrag(self.x,self.y);
  end;

  procedure TglvgGuiControl.MouseIn;
  begin
    self.FMouseOver:=true;
  end;

  procedure TglvgGuiControl.MouseOut;
  begin
   self.FMouseOver:=false;
  end;

  procedure TglvgGuiControl.Click;
  begin
    //handle mouseclick
    if Assigned(FOnClick) then
      FOnClick();
    self.FMouseOver:=false; //trigger mouse over again aftter click event
  end;

  procedure TglvgGuiControl.HandleMouseEvent(mousex: integer; mousey: integer; mousemovex: integer; mousemovey: integer; leftclick: boolean; dragclick: boolean);
  var
    i: integer;
    minX,minY,maxX,maxY: single;
  begin
    if fIsDragged and not dragclick then
      begin
        //writeln('end drag');
        fIsDragged := false;
      end;

    minX := self.X;
    maxX := self.X + self.Width;
    minY := self.Y;
    maxY := self.Y + self.Height;

    if (fIsDragged) then
      begin
        //be less accurate while dragging
        minX := self.X-100;
        maxX := self.X + self.Width+100;
        minY := self.Y-100;
        maxY := self.Y + self.Height+100;
      end;

     if ( (MouseX > minX) AND (MouseX < maxX) and (MouseY > minY) and (MouseY < maxY) ) then
           begin
             //pass on event to child controls
             for i := 0 to self.ComponentCount-1 do
             begin
               TglvgGuiControl(self.Components[i]).HandleMouseEvent(mousex,mousey,mousemovex,mousemovey,leftclick,dragclick);
             end;
             //next handle itself
             if self.Elements.Count >=1 then
                begin

                  if self.FMouseOver then self.MouseOver else self.MouseIn;

                  if leftclick then
                  begin
                      self.Click;
                  end;

                  if dragclick and fdraggable then
                  begin
                    //move control
                    fIsDragged:=true;
                    self.X:=self.X+mouseMoveX;
                    self.Y:=self.Y+mouseMoveY;
                    self.MouseDrag;
                  end;
                end;
           end else begin
             if (self.Elements.Count >=1) and self.FMouseOver then
             begin
               self.MouseOut;
               for i := 0 to self.ComponentCount-1 do
               begin
                 TglvgGuiControl(self.Components[i]).MouseOut; //send it again to prevent hanging hovered child components
               end;
             end;
           end;
  end;

  //TglvgGuiWindow

  constructor TglvgGuiWindow.Create(aowner:TComponent);
  begin
    inherited Create(aowner);
  end;

  //TglvgGuiNode

  constructor TglvgGuiNode.Create(aowner:TComponent);
  begin
    inherited create(aowner);
    self.fBackGround := tglvgGuiWindow.Create(self);
    self.fFrom := TglvgGuiConnector.Create(self);
    self.fTo := TglvgGuiConnector.Create(self);
  end;

  procedure TglvgGuiNode.Init;
  begin
    self.fFrom.X:=self.X;
    self.fFrom.Y:=self.Y-5+self.Height/2;
    self.fFrom.DraggAble:=false;
    self.fFrom.Init;

    self.fTo.X:=self.X-10+self.Width;
    self.fTo.Y:=self.y-5+self.Height/2;
    self.fTo.DraggAble:=false;
    self.fTo.Init;

    self.fBackGround.DraggAble:=true;
    self.fBackGround.Elements.AddElement(TglvgRect.Create);

    TglvgRect(self.fBackGround.Elements.Element[0]).X:=self.x+5;
    TglvgRect(self.fBackGround.Elements.Element[0]).Y:=self.y;
    TglvgRect(self.fBackGround.Elements.Element[0]).Width:=self.width-10;
    TglvgRect(self.fBackGround.Elements.Element[0]).Height:=self.height;
    TglvgRect(self.fBackGround.Elements.Element[0]).Style.Color.SetColor(0,0,1,1);
    TglvgRect(self.fBackGround.Elements.Element[0]).Style.FillType:=glvgsolid;
    TglvgRect(self.fBackGround.Elements.Element[0]).Init;


    self.Elements.AddElement(TglvgRect.Create);
    TglvgRect(self.Elements.Element[0]).X:=0;
    TglvgRect(self.Elements.Element[0]).Y:=0;
    TglvgRect(self.Elements.Element[0]).Width:=self.width;
    TglvgRect(self.Elements.Element[0]).Height:=self.height;
    TglvgRect(self.Elements.Element[0]).Style.Color.SetColor(1,0,0,1);
    TglvgRect(self.Elements.Element[0]).Style.FillType:=glvgnone;
    TglvgRect(self.Elements.Element[0]).Style.LineType:=glvgnone;
    TglvgRect(self.Elements.Element[0]).Init;


  end;

  procedure TglvgGuiNode.Render;
  begin

    inherited Render;
    self.fTo.Render;
    self.fFrom.Render;
    self.fBackGround.Render;

  end;

  //TglvgGuiConnection
  constructor TglvgGuiConnection.Create(aowner:TComponent);
  begin
    inherited Create(aowner);

    self.Elements.AddElement(TglvgPolyLine.Create());

    TglvgPolyLine(self.Elements.Element[0]).Polygon.Style.FillType:=glvgNone;
    TglvgPolyLine(self.Elements.Element[0]).Polygon.Style.LineWidth := 1.0;
    TglvgPolyLine(self.Elements.Element[0]).Polygon.Style.LineColor.SetColor(1,1,1,1);

  end;

  procedure TglvgGuiConnection.Init;
  var
    linepath: string;
  begin
    self.Width:=self.fToX-self.fX+5;
    self.Height:=self.fToY-self.fY+5;
    linepath:='M ';
    linepath:=linepath+floattostr(0)+','+floattostr(0)+' ';
    linepath:=linepath+'C '+floattostr(0+(abs(0-self.Width)/2))+','+floattostr(0)+' ';
    linepath:=linepath+floattostr(0+(abs(0-self.Width)/2))+','+floattostr(self.Height)+' ';
    linepath:=linepath+floattostr(self.Width)+','+floattostr(self.Height);
    TglvgPolyLine(self.Elements.Element[0]).Polygon.Path := linepath;
    TglvgPolyLine(self.Elements.Element[0]).Polygon.Style.LineColor.SetColor(1,0,0,1);
  end;

  procedure TglvgGuiConnection.MouseIn;
  begin
    TglvgPolyLine(self.Elements.Element[0]).Polygon.Style.LineColor.SetColor(0,0,1,1);
    inherited MouseIn;
  end;

  procedure TglvgGuiConnection.MouseOut;
  begin
   TglvgPolyLine(self.Elements.Element[0]).Polygon.Style.LineColor.SetColor(1,1,1,1);
   inherited MouseOut;
  end;

  //TglvgGuiConnector

  constructor TglvgGuiConnector.Create(aowner:TComponent);
  begin
    inherited Create(aowner);
    self.fDraggAble:=true;
    self.Elements.AddElement(TglvgCircle.Create());
  end;

  procedure TglvgGuiConnector.Init;
  begin
    TglvgCircle(self.Elements.Element[0]).Radius:=5;
    TglvgCircle(self.Elements.Element[0]).X:=5;
    TglvgCircle(self.Elements.Element[0]).Y:=5;
    self.Width:=10;
    self.Height:=10;
    TglvgCircle(self.Elements.Element[0]).Style.Color.SetColor(0,0,0,1);
    TglvgCircle(self.Elements.Element[0]).Style.LineColor.SetColor(1,1,1,1);
    TglvgCircle(self.Elements.Element[0]).Style.FillType:=glvgsolid;
    TglvgCircle(self.Elements.Element[0]).Init;
  end;

  procedure TglvgGuiConnector.MouseIn;
  begin
    TglvgCircle(self.Elements.Element[0]).Style.Color.SetColor(1,1,1,1);
    TglvgCircle(self.Elements.Element[0]).Init;
    inherited MouseIn;
  end;

  procedure TglvgGuiConnector.MouseOut;
  begin
   TglvgCircle(self.Elements.Element[0]).Style.Color.SetColor(0,0,0,1);
   TglvgCircle(self.Elements.Element[0]).Init;
   inherited MouseOut;
  end;

  //TglvgGuiButton

  constructor TglvgGuiButton.Create(aowner:TComponent);
  begin
    inherited Create(aowner);
    fDrawText := tglvgText.Create;
  end;

  destructor TglvgGuiButton.Destroy;
  begin
    fDrawText.Free;
    inherited Destroy;
  end;

  procedure TglvgGuiButton.Init;
  begin
    self.Elements.AddElement(TglvgRect.Create);

    TglvgRect(self.Elements.Element[0]).X := 0;
    TglvgRect(self.Elements.Element[0]).Y := 0;

    TglvgRect(self.Elements.Element[0]).Width := fWidth;
    TglvgRect(self.Elements.Element[0]).Height := fHeight;

    TglvgRect(self.Elements.Element[0]).Rx := 15;
    TglvgRect(self.Elements.Element[0]).Ry := 15;

    TglvgRect(self.Elements.Element[0]).Style.NumGradColors:=2;
    TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#00C0C0');
    TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#0000C0');

    TglvgRect(self.Elements.Element[0]).Style.FillType := glvgLinearGradient;
    TglvgRect(self.Elements.Element[0]).Style.LineType := glvgNone;

    TglvgRect(self.Elements.Element[0]).Init;

    //HighLight 1
    self.Elements.AddElement(TglvgRect.Create);
    TglvgRect(self.Elements.Element[1]).X := 2.5;
    TglvgRect(self.Elements.Element[1]).Y := 2.5;

    TglvgRect(self.Elements.Element[1]).Width := fWidth - 5;
    TglvgRect(self.Elements.Element[1]).Height := fHeight - 10;

    TglvgRect(self.Elements.Element[1]).Rx := 15;
    TglvgRect(self.Elements.Element[1]).Ry := 15;

    TglvgRect(self.Elements.Element[1]).Style.Color.SetColor('#FFFFFF');
    TglvgRect(self.Elements.Element[1]).Style.NumGradColors:=2;
    TglvgRect(self.Elements.Element[1]).Style.GradColorAngle:=90;
    TglvgRect(self.Elements.Element[1]).Style.GradColor[0].a:=1.0;
    TglvgRect(self.Elements.Element[1]).Style.GradColor[0].x:=0.0;
    TglvgRect(self.Elements.Element[1]).Style.GradColor[1].x:=10.0;
    TglvgRect(self.Elements.Element[1]).Style.GradColor[1].a:=0.0;
    TglvgRect(self.Elements.Element[1]).Style.FillType := glvgLinearGradient;
    TglvgRect(self.Elements.Element[1]).Style.LineType := glvgNone;

    TglvgRect(self.Elements.Element[1]).Init;

    //HighLight 2
    self.Elements.AddElement(TglvgRect.Create);
    TglvgRect(self.Elements.Element[2]).X := 2.5;
    TglvgRect(self.Elements.Element[2]).Y := 30 - 2.5 - 20;

    TglvgRect(self.Elements.Element[2]).Width := fWidth - 5;
    TglvgRect(self.Elements.Element[2]).Height := fHeight - 10;

    TglvgRect(self.Elements.Element[2]).Rx := 15;
    TglvgRect(self.Elements.Element[2]).Ry := 15;

    TglvgRect(self.Elements.Element[2]).Style.Color.SetColor('#000000');
    TglvgRect(self.Elements.Element[2]).Style.NumGradColors:=2;
    TglvgRect(self.Elements.Element[2]).Style.GradColorAngle:=90;
    TglvgRect(self.Elements.Element[2]).Style.GradColor[0].SetColor('#000000');
    TglvgRect(self.Elements.Element[2]).Style.GradColor[0].a:=0.0;
    TglvgRect(self.Elements.Element[2]).Style.GradColor[0].x:=15;

    TglvgRect(self.Elements.Element[2]).Style.GradColor[1].SetColor('#000000');
    TglvgRect(self.Elements.Element[2]).Style.GradColor[1].x:=29;
    TglvgRect(self.Elements.Element[2]).Style.GradColor[1].a:=1.0;

    TglvgRect(self.Elements.Element[2]).Style.FillType := glvgLinearGradient;
    TglvgRect(self.Elements.Element[2]).Style.LineType := glvgNone;

    TglvgRect(self.Elements.Element[2]).Init;

    //text
    fDrawText.X:=self.X+10;
    fDrawText.Y:=self.Y+7;
    fDrawText.Font.Size:=12;
    fDrawText.Text:='Dummy';
    fDrawText.Style.Color.SetColor(1,1,1,1);
    fDrawText.Style.FillType:=glvgsolid;
    fDrawText.Style.LineType:=glvgnone;
    fDrawText.Init;
    //self.Elements.AddElement(FDrawText); //Does not render it when set this way
  end;

  procedure TglvgGuiButton.MouseIn;
  begin
    TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#0000C0');
    TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#00C0C0');
    TglvgRect(self.Elements.Element[0]).Init;
    inherited MouseIn;
  end;

  procedure TglvgGuiButton.MouseOut;
  begin
   TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#00C0C0');
   TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#0000C0');
   TglvgRect(self.Elements.Element[0]).Init;
   inherited MouseOut;
  end;

  procedure TglvgGuiButton.Click;
  begin
    //handle mouseclick
    TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#0000C0');
    TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#0000C0');
    TglvgRect(self.Elements.Element[0]).Init;
    inherited Click;
    //TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#00C0C0');
    //TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#0000C0');
    //TglvgRect(self.Elements.Element[0]).Init;
  end;

  procedure TglvgGuiButton.Render;
  begin
    inherited Render;
    self.Caption.Render;
  end;

  //TglvgGuiGrid
  procedure TglvgGuiGrid.SetCell(x: Integer; y: Integer; value: string);
  begin
    FCells[x,y] := value;
  end;

  function TglvgGuiGrid.GetCell(x: Integer; y: Integer): string;
  begin
    result := FCells[x,y];
  end;

  procedure TglvgGuiGrid.SetRowCount(value: Integer);
  var
    I: Integer;
  begin
    FRowCount := Value;
    SetLength(FCells, Value);
    for I := 0 to frowcount - 1 do
      setlength(FCells[I], fcolcount);
  end;

  procedure TglvgGuiGrid.SetColCount(value: Integer);
  var
    I: Integer;
  begin
    FColCount:=Value;
    for I := 0 to frowcount - 1 do
      setlength(FCells[I], Value);
  end;

end.
