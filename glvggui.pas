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

uses glvg, types, classes;

type
//Experimental idea for making a vector gui ... (or group control)

TOnClickEvent = procedure(x: integer; y: integer) of Object;

TglvgGuiControl = class(TComponent)
private
  FElements: TglvgGroup;
//  FNumElements: integer;
  FMouseOver: boolean;
  FClicked: boolean;
  FX: single;
  FY: single;
  FWidth: single;
  FHeight: single;
  fonClick : TonClickEvent;
//  function  GetElement(Index: Integer): TglvgObject;
//  procedure SetElement(Index: Integer; Value: TglvgObject);
public
  Constructor Create(aowner:TComponent);
//  Destructor Destroy(); override;
//  procedure AddElement(AElement: TglvgObject);

  procedure Render;
  procedure RenderMouseOver;
  procedure RenderClicked;
  procedure GetState;
  procedure HandleMouseEvent(mousex: integer; mousey: integer; leftclick: boolean);
  property X: single read Fx write Fx;
  property Y: single read Fy write Fy;
  property Width: single read FWidth write FWidth;
  property Height: single read FHeight write FHeight;
  property OnClick: TonClickEvent read fonClick write fonClick;
  property Elements: TglvgGroup read fElements write fElements;
//  property Element[index: integer]: TglvgObject read GetElement write SetElement;
end;

TglvgGuiWindow = class ( TglvgGuiControl )
public
  Constructor Create(aowner:Tcomponent);
end;

TglvgGuiButton = class ( TglvgGuiControl )
private
  fdrawtext : TglvgText;
  ftext : string;
public
  Constructor Create(aowner:Tcomponent);
  procedure Init;
  property Text: string read ftext write ftext;
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

//TglvguiObject

  constructor TglvgGuiControl.Create(aowner: TComponent);
  begin
    inherited Create(aowner);
    fElements := TglvgGroup.Create();
    //FNumElements:=0;
  end;

(*  destructor TglvgGuiControl.Destroy;
  var
    i: integer;
  begin
    if FElements <> nil then
    begin
      For i:=FNumElements-1 downto 0 do
      begin
        FElements[i].Free;
      end;
    end;

    SetLength(FElements,0);
    inherited Destroy;
  end;


  procedure TglvgGuiControl.AddElement(AElement: TglvgObject);
  begin
    FNumElements:=FNumElements+1;
    SetLength(FElements,FNumElements);
    FElements[FNumElements-1] := AElement;
  end;
   *)
  procedure TglvgGuiControl.Render;
  var
    i: integer;
  begin
    glpushmatrix();
      gltranslatef(Fx,Fy,0);
      //glscalef(5,5,1); //DEBUG scaling...
      for i:=0 to self.Elements.Count-1 do
      begin
        self.Elements.Element[i].Render;
      end;
    glpopmatrix();
  end;

  procedure TglvgGuiControl.HandleMouseEvent(mousex: integer; mousey: integer; leftclick: boolean);
  var i: integer;
  begin


     if (MouseX > self.X) AND (MouseX < self.X + self.Width) then
        if (MouseY > self.Y) AND (MouseY < self.Y + self.Height) then
           begin
             //pass on event to child controls
             for i := 0 to self.ComponentCount-1 do
             begin
               TglvgGuiControl(self.Components[i]).HandleMouseEvent(mousex,mousey,leftclick);
             end;
             //next handle itself
             if self.Elements.Count >=1 then
                begin
                  //this should be in tbutton
                  TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#0000C0');
                  TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#00C0C0');
                  self.FMouseOver:=true;
                  if leftclick then
                  begin
                    //handle mouseclick
                    TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#0000C0');
                    TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#0000C0');
                    if Assigned(FOnClick) then FOnClick(mousex,mousey);
                  end;
                end;
           end else begin
             if self.Elements.Count >=1 then
             begin
               TglvgRect(self.Elements.Element[0]).Style.GradColor[0].SetColor('#00C0C0');
               TglvgRect(self.Elements.Element[0]).Style.GradColor[1].SetColor('#0000C0');
               self.FMouseOver:=false;
             end;
           end;

     if self.Elements.Count >=1 then
       TglvgRect(self.Elements.Element[0]).Init;
  end;

  procedure TglvgGuiControl.RenderMouseOver;
  begin
  end;

  procedure TglvgGuiControl.RenderClicked;
  begin
  end;

  procedure TglvgGuiControl.GetState;
  begin
  end;

(*  function  TglvgGuiControl.GetElement(Index: Integer): TglvgObject;
  begin
    result := fElements[Index];
  end;

  procedure TglvgGuiControl.SetElement(Index: Integer; Value: TglvgObject);
  begin
    fElements[Index] := Value;
  end;  *)

  constructor TglvgGuiWindow.Create(aowner:TComponent);
  begin
    inherited Create(aowner);
  end;

  constructor TglvgGuiButton.Create(aowner:TComponent);
  begin
    inherited Create(aowner);
    fDrawText := tglvgText.Create;
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

    //hl1
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

    //hl2

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

    self.Elements.AddElement(FDrawText);
  end;

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
