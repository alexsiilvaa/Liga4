unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects,
  FMX.DialogService;

type
  TCor = (cAzul = 0, cAmarelo = 1, cBranco = 2);
  TJogador = TCor.cAzul .. TCor.cAmarelo;

const
  TCorText: array [TCor] of String = ('Azul', 'Amarelo', 'Nenhuma');
  TCorJogador: array [TCor] of TAlphaColor = (TAlphaColorRec.Blue,
    TAlphaColorRec.Yellow, TAlphaColorRec.White);

Type
  TTipoCirculo = record
    Cor: TCor;
    Utilizado: Boolean;
    Circulo: TCircle;
  end;

  TFMain = class(TForm)
    StyleBook1: TStyleBook;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FCirculo: Array [1 .. 7, 1 .. 6] of TTipoCirculo;
    FJogador: TJogador;

    procedure CriarCirulo;
    procedure CliqueCirculo(Sender: TObject);
    procedure VerificaGanhador(const pX, pY: Integer);
    procedure setNovoJogo(const pCor: TCor);
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TFMain.CliqueCirculo(Sender: TObject);
var
  lRow, lX: Integer;
begin
  if not(Sender is TCircle) then
  begin
    Exit;
  end;

  lX := StrToInt(Copy(TCircle(Sender).Name, 2, 1));

  for lRow := 6 downto 1 do
  begin
    if not FCirculo[lX, lRow].Utilizado then
    begin
      FCirculo[lX, lRow].Utilizado := True;
      FCirculo[lX, lRow].Circulo.Fill.Color := TCorJogador[FJogador];
      FCirculo[lX, lRow].Cor := FJogador;

      FJogador := TCor((ord(FJogador) +1) mod 2 );
      VerificaGanhador(lX, lRow);
      Break;
    end;

    if lRow = 1 then
    begin
      Showmessage('Todos os campos estão em uso, utilize outra coluna.');
    end;
  end;
end;

procedure TFMain.CriarCirulo;
var
  lX, lY: Integer;
begin
  for lX := 1 to 7 do
    for lY := 1 to 6 do
    begin
      FCirculo[lX, lY].Utilizado := False;
      FCirculo[lX, lY].Cor := cBranco;
      FCirculo[lX, lY].Circulo := TCircle.Create(Self);

      with FCirculo[lX, lY].Circulo do
      begin
        Visible := False;
        Parent := Self;
        Name := 'C' + IntToStr(lX) + IntToStr(lY);
        Position.X := (lX - 1) * 50 + (lX) * 10;
        Position.Y := (lY - 1) * 50 + (lY) * 10;
        Height := 50;
        Width := 50;
        Tag := 0;
        Cursor := crHandPoint;
        Fill.Color := TCorJogador[cBranco];
        OnClick := CliqueCirculo;
        Visible := True;
      end;
    end;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  FJogador := cAmarelo;
  Self.CriarCirulo;
end;

procedure TFMain.setNovoJogo(const pCor: TCor);
var
  lX, lY: Integer;
begin
  TDialogService.MessageDialog(TCorText[pCor] + ' Você Ganhou!!!',
    TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);

  FJogador := cAmarelo;

  for lX := 1 to 7 do
    for lY := 1 to 6 do
    begin
      FCirculo[lX, lY].Cor := cBranco;
      FCirculo[lX, lY].Utilizado := False;
      FCirculo[lX, lY].Circulo.Fill.Color := TAlphaColorRec.White;
    end;
end;

procedure TFMain.VerificaGanhador(const pX, pY: Integer);
var
  lRow, lRow2, lCountAntes, lCountDepois: Integer;
begin
  /// ///////////////////// vertical \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  lCountAntes := 0;
  for lRow := pY downto 1 do
    if lRow <> pY then
      if FCirculo[pX, lRow].Utilizado and
        (FCirculo[pX, pY].Cor = FCirculo[pX, lRow].Cor) then
        inc(lCountAntes)
      else
        Break;

  lCountDepois := 0;
  for lRow := pY to 6 do
    if lRow <> pY then
      if FCirculo[pX, lRow].Utilizado and
        (FCirculo[pX, pY].Cor = FCirculo[pX, lRow].Cor) then
        inc(lCountDepois)
      else
        Break;

  if (lCountAntes + lCountDepois + 1) >= 4 then
  begin
    Self.setNovoJogo(FCirculo[pX, pY].Cor);
    Exit;
  end;

  /// ///////////////////// horizontal \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  lCountAntes := 0;
  for lRow := pX downto 1 do
    if lRow <> pX then
      if FCirculo[lRow, pY].Utilizado and
        (FCirculo[pX, pY].Cor = FCirculo[lRow, pY].Cor) then
        inc(lCountAntes)
      else
        Break;

  lCountDepois := 0;
  for lRow := pX to 7 do
    if lRow <> pX then
      if FCirculo[lRow, pY].Utilizado and
        (FCirculo[pX, pY].Cor = FCirculo[lRow, pY].Cor) then
        inc(lCountDepois)
      else
        Break;

  if (lCountAntes + lCountDepois + 1) >= 4 then
  begin
    Self.setNovoJogo(FCirculo[pX, pY].Cor);
    Exit;
  end;

  /// ///////////////////// diagonal 1 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  lCountAntes := 0;
  lRow2 := pY - 1;
  for lRow := pX downto 1 do
  begin
    if lRow <= 0 then
      Break;
    if lRow2 <= 0 then
      Break;

    if FCirculo[lRow - 1, lRow2].Utilizado and
      (FCirculo[pX, pY].Cor = FCirculo[lRow - 1, lRow2].Cor) then
      inc(lCountAntes)
    else
      Break;

    lRow2 := lRow2 - 1;
  end;

  lCountDepois := 0;
  lRow2 := pY + 1;
  for lRow := pX to 7 do
  begin
    if lRow >= 8 then
      Break;
    if lRow2 >= 7 then
      Break;

    if FCirculo[lRow + 1, lRow2].Utilizado and
      (FCirculo[pX, pY].Cor = FCirculo[lRow + 1, lRow2].Cor) then
      inc(lCountDepois)
    else
      Break;

    inc(lRow2);
  end;

  if (lCountAntes + lCountDepois + 1) >= 4 then
  begin
    Self.setNovoJogo(FCirculo[pX, pY].Cor);
    Exit;
  end;

  /// ///////////////////// diagonal 2 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  lCountAntes := 0;
  lRow2 := pY + 1;
  for lRow := pX downto 1 do
  begin
    if lRow <= 0 then
      Break;
    if lRow2 >= 7 then
      Break;

    if FCirculo[lRow - 1, lRow2].Utilizado and
      (FCirculo[pX, pY].Cor = FCirculo[lRow - 1, lRow2].Cor) then
      inc(lCountAntes)
    else
      Break;

    lRow2 := lRow2 + 1;
  end;

  lCountDepois := 0;
  lRow2 := pY - 1;
  for lRow := pX to 7 do
  begin
    if lRow >= 8 then
      Break;
    if lRow2 <= 0 then
      Break;

    if FCirculo[lRow + 1, lRow2].Utilizado and
      (FCirculo[pX, pY].Cor = FCirculo[lRow + 1, lRow2].Cor) then
      inc(lCountDepois)
    else
      Break;

    lRow2 := lRow2 - 1;
  end;

  if (lCountAntes + lCountDepois + 1) >= 4 then
  begin
    Self.setNovoJogo(FCirculo[pX, pY].Cor);
    Exit;
  end;
end;

end.
