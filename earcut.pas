unit earcut;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  classes, glPolygon;

type
  TMyPolygon = array of TPolygonPoint;
  TTriangle = array[0..2] of TPolygonPoint;
  TTriangles = array of TTriangle;
  PPoint = ^TPolygonPoint;

function Triangulate(APolygon: TMyPolygon; var ATriangles: TTriangles):boolean;

implementation

function Triangulate(APolygon: TMyPolygon; var ATriangles: TTriangles):boolean;
var
  lst:TList;
  i, j:integer;
  p, p1, p2, pt: PPoint;
  l:double;
  intriangle : boolean;
  lastear : integer;

  //Berechnet aus einem Index, der auch die Listen-Grenzen über- oder unterschreiten
  //kann einen validen Listenindex.
  function GetItem(const ai, amax:integer):integer;
  begin
    result := ai mod amax;
    if result < 0 then
      result := amax + result;
  end;

  function Point(x: single; y: single; r: single; g: single; b: single; a: single): TPolygonPoint;
  begin
    result.x:=x;
    result.y:=y;
    result.z:=0;
    result.r:=r;
    result.g:=g;
    result.b:=b;
    result.a:=a;
  end;

  //Überprüft ob ein Punkt in einem Dreieck liegt
  function PointInTriangle(const ap1, tp1, tp2, tp3 : TPolygonPoint): boolean;
  var
    b0, b1, b2, b3: Double;
  begin
    b0 := ((tp2.x - tp1.x) * (tp3.y - tp1.y) - (tp3.x - tp1.x) * (tp2.y - tp1.y));
    if b0 <> 0 then
    begin
      b1 := (((tp2.x - ap1.x) * (tp3.y - ap1.y) - (tp3.x - ap1.x) * (tp2.y - ap1.y)) / b0);
      b2 := (((tp3.x - ap1.x) * (tp1.y - ap1.y) - (tp1.x - ap1.x) * (tp3.y - ap1.y)) / b0);
      b3 := 1 - b1 - b2;

      result := (b1 > 0) and (b2 > 0) and (b3 > 0);
    end else
      result := false;
  end;

begin
  lst := TList.Create;

  //Kopiere die Punkte des Polygons in eine TList (also eine Vektordatenstruktur)
  for i := 0 to High(APolygon) do
  begin
    New(p);
    p^.X := APolygon[i].X;
    p^.Y := APolygon[i].Y;
    lst.Add(p);
  end;

  i := 0;
  lastear := -1;
  repeat
    lastear := lastear + 1;

    //Suche drei benachbarte Punkte aus der Liste
    p1 := lst.Items[GetItem(i - 1, lst.Count)];
    p  := lst.Items[GetItem(i, lst.Count)];
    p2 := lst.Items[GetItem(i + 1, lst.Count)];

    //Berechne, ob die Ecke konvex oder konkav ist
    l := ((p1.X - p.X) * (p2.Y - p.Y) - (p1.Y - p.Y) * (p2.X - p.X));

    //Nur weitermachen, wenn die Ecke konvex ist
    if l < 0 then
    begin
      //Überprüfe ob irgendein anderer Punkt aus dem Polygon
      //das ausgewählte Dreieck schneidet
      intriangle := false;
      for j := 2 to lst.Count - 2 do
      begin
        pt := lst.Items[GetItem(i + j, lst.Count)];
        if PointInTriangle(pt^, p1^, p^, p2^) then
        begin
          intriangle := true;
          break;
        end;
      end;

      //Ist dies nicht der Fall, so entferne die ausgwewählte Ecke und bilde
      //ein neues Dreieck
      if not intriangle then
      begin
        SetLength(ATriangles, Length(ATriangles) + 1);
        ATriangles[High(ATriangles)][0] := Point(p1^.X, p1^.Y, p1^.r, p1^.g, p1^.b, p1^.a);
        ATriangles[High(ATriangles)][1] := Point(p^.X, p^.Y, p^.r, p^.g, p^.b, p^.a);
        ATriangles[High(ATriangles)][2] := Point(p2^.X, p2^.Y, p2^.r, p2^.g, p2^.b, p2^.a);

        lst.Delete(GetItem(i, lst.Count));
        Dispose(p);

        lastear := 0;

        i := i-3;
      end;

    end;

    i := i + 1;
    if i > lst.Count - 1 then
      i := 0;

  //Abbrechen, wenn nach zwei ganzen Durchläufen keine Ecke gefunden wurde, oder nur noch
  //drei Ecken übrig sind.
  until (lastear > lst.Count*2) or (lst.Count = 3);

  if lst.Count = 3 then
  begin
    p1 := lst.Items[GetItem(0, lst.Count)];
    p  := lst.Items[GetItem(1, lst.Count)];
    p2 := lst.Items[GetItem(2, lst.Count)];
    SetLength(ATriangles, Length(ATriangles) + 1);
    ATriangles[High(ATriangles)][0] := Point(p1^.X, p1^.Y, p1^.r, p1^.g, p1^.b, p1^.a);
    ATriangles[High(ATriangles)][1] := Point(p^.X, p^.Y, p^.r, p^.g, p^.b, p^.a);
    ATriangles[High(ATriangles)][2] := Point(p2^.X, p2^.Y, p2^.r, p2^.g, p2^.b, p2^.a);
  end;
  result := lst.Count = 3;

  for i := 0 to lst.Count - 1 do
  begin
    Dispose(PPoint(lst.Items[i]));
  end;
  lst.Clear;
  lst.Free;

end;

end.

