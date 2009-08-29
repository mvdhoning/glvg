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

uses glvg, types;

type
//Experimental idea for making a vector gui ... (or group control)
TglvgGuiObject = class(TglvgGroup)
private
//  FElements: array of TglvgObject;
//  FNumElements: integer;
  FMouseOver: boolean;
  FClicked: boolean;
  FX: single;
  FY: single;
  FWidth: single;
  FHeight: single;
//  function  GetElement(Index: Integer): TglvgObject;
//  procedure SetElement(Index: Integer; Value: TglvgObject);
public
  Constructor Create();
//  Destructor Destroy(); override;
//  procedure AddElement(AElement: TglvgObject);
  procedure Render;
  procedure RenderMouseOver;
  procedure RenderClicked;
  procedure GetState;
  property X: single read Fx write Fx;
  property Y: single read Fy write Fy;
  property Width: single read FWidth write FWidth;
  property Height: single read FHeight write FHeight;
//  property Element[index: integer]: TglvgObject read GetElement write SetElement;
end;

TglvgGuiButton = class ( TglvgGuiObject )
private
  fdrawtext : TglvgText;
  ftext : string;
public
  Constructor Create();
  procedure Init;
  property Text: string read ftext write ftext;
end;

TglvgGuiGridDrawState = set of (gdSelected, gdFocused, gdFixed);


TglvgGuiGrid = class ( TglvgGuiObject )
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

  constructor TglvgGuiObject.Create;
  begin
    inherited Create();
    //FNumElements:=0;
  end;

(*  destructor TglvgGuiObject.Destroy;
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


  procedure TglvgGuiObject.AddElement(AElement: TglvgObject);
  begin
    FNumElements:=FNumElements+1;
    SetLength(FElements,FNumElements);
    FElements[FNumElements-1] := AElement;
  end;
   *)
  procedure TglvgGuiObject.Render;
  var
    i: integer;
  begin
    glpushmatrix();
      gltranslatef(Fx,Fy,0);
      //glscalef(5,5,1); //DEBUG scaling...
      for i:=0 to self.Count do
      begin
        Element[i].Render;
      end;
    glpopmatrix();
  end;


  procedure TglvgGuiObject.RenderMouseOver;
  begin
  end;

  procedure TglvgGuiObject.RenderClicked;
  begin
  end;

  procedure TglvgGuiObject.GetState;
  begin
  end;

(*  function  TglvgGuiObject.GetElement(Index: Integer): TglvgObject;
  begin
    result := fElements[Index];
  end;

  procedure TglvgGuiObject.SetElement(Index: Integer; Value: TglvgObject);
  begin
    fElements[Index] := Value;
  end;  *)

  constructor TglvgGuiButton.Create;
  begin
    inherited Create();

    fDrawText := tglvgText.Create;

//    FNumElements:=0;



  end;

  procedure TglvgGuiButton.Init;
  begin
      AddElement(TglvgRect.Create);
    TglvgRect(Element[0]).X := 0;
    TglvgRect(Element[0]).Y := 0;

    TglvgRect(Element[0]).Width := fWidth;
    TglvgRect(Element[0]).Height := fHeight;

    TglvgRect(Element[0]).Rx := 15;
    TglvgRect(Element[0]).Ry := 15;

    TglvgRect(Element[0]).Style.NumGradColors:=2;
    TglvgRect(Element[0]).Style.GradColor[0].SetColor('#00C0C0');
    TglvgRect(Element[0]).Style.GradColor[1].SetColor('#0000C0');

    TglvgRect(Element[0]).Style.FillType := glvgLinearGradient;
    TglvgRect(Element[0]).Style.LineType := glvgNone;

    TglvgRect(Element[0]).Init;

    //hl1
    AddElement(TglvgRect.Create);
    TglvgRect(Element[1]).X := 2.5;
    TglvgRect(Element[1]).Y := 2.5;

    TglvgRect(Element[1]).Width := fWidth - 5;
    TglvgRect(Element[1]).Height := fHeight - 10;

    TglvgRect(Element[1]).Rx := 15;
    TglvgRect(Element[1]).Ry := 15;

    TglvgRect(Element[1]).Style.Color.SetColor('#FFFFFF');

    TglvgRect(Element[1]).Style.NumGradColors:=2;
    TglvgRect(Element[1]).Style.GradColor[0].a:=1.0;
    TglvgRect(Element[1]).Style.GradColor[0].y:=0.0;
    TglvgRect(Element[1]).Style.GradColor[1].y:=10.0;
    TglvgRect(Element[1]).Style.GradColor[1].a:=0.0;


    TglvgRect(Element[1]).Style.FillType := glvgSolid;
//    TglvgRect(FElements[1]).Style.AlphaFillType := glvgLinearGradient;
    TglvgRect(Element[1]).Style.LineType := glvgNone;

    TglvgRect(Element[1]).Init;

    //hl2

    AddElement(TglvgRect.Create);
    TglvgRect(Element[2]).X := 2.5;
    TglvgRect(Element[2]).Y := 30 - 2.5 - 20;

    TglvgRect(Element[2]).Width := fWidth - 5;
    TglvgRect(Element[2]).Height := fHeight - 10;

    TglvgRect(Element[2]).Rx := 15;
    TglvgRect(Element[2]).Ry := 15;

    TglvgRect(Element[2]).Style.Color.SetColor('#000000');
    TglvgRect(Element[2]).Style.NumGradColors:=2;
    TglvgRect(Element[2]).Style.GradColor[0].a:=0.0;
    TglvgRect(Element[2]).Style.GradColor[0].y:=20.0;
    TglvgRect(Element[2]).Style.GradColor[1].y:=30.0;
    TglvgRect(Element[2]).Style.GradColor[1].a:=1.0;


    TglvgRect(Element[2]).Style.FillType := glvgSolid;
//    TglvgRect(FElements[2]).Style.AlphaFillType := glvgLinearGradient;
    TglvgRect(Element[2]).Style.LineType := glvgNone;

    TglvgRect(Element[2]).Init;

    AddElement(FDrawText);
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
