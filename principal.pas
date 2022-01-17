unit principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, Vcl.Buttons, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg, Vcl.DBCtrls, XDBCtrls;

type
  TtabelaType = (tblAnos, tblCombustiveis, tblFotos, tblMarcas, tblModelos, tblMontadoras,
    tblMotores, tblSegmentos, tblProdutos);

  TForm1 = class(TForm)
    sbtnAnos: TSpeedButton;
    fdcFBVendaM: TFDConnection;
    fdcPgVendaM: TFDConnection;
    FDPhysPgDriverLink1: TFDPhysPgDriverLink;
    fdtPg: TFDTransaction;
    sbtnCombustiveis: TSpeedButton;
    stbnFotos: TSpeedButton;
    sbtnMarcas: TSpeedButton;
    sbtnMontadoras: TSpeedButton;
    sbtnModelos: TSpeedButton;
    sbtnMotores: TSpeedButton;
    sbtnSegementos: TSpeedButton;
    sbtnProdutos: TSpeedButton;
    lblCodInicial: TLabel;
    lblCodFinal: TLabel;
    lblHI: TLabel;
    lblHF: TLabel;
    sbtnTransformar: TSpeedButton;
    edtCodigo: TEdit;
    imgFotoBck1: TImage;
    imgFotoBck2: TImage;
    SpeedButton1: TSpeedButton;
    lblCod: TLabel;
    lblTotal: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    imgFoto1: TImage;
    imgFoto2: TImage;
    lblDescricao: TLabel;
    DataSource1: TDataSource;
    fdqProdutos: TFDQuery;
    xndbProdutos: TXDBNavigator;
    procedure sbtnAnosClick(Sender: TObject);
    procedure sbtnCombustiveisClick(Sender: TObject);
    procedure stbnFotosClick(Sender: TObject);
    procedure sbtnMarcasClick(Sender: TObject);
    procedure sbtnMontadorasClick(Sender: TObject);
    procedure sbtnModelosClick(Sender: TObject);
    procedure sbtnMotoresClick(Sender: TObject);
    procedure sbtnSegementosClick(Sender: TObject);
    procedure sbtnProdutosClick(Sender: TObject);
    procedure transformarImgFbPg(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure xndbProdutosClick(Sender: TObject; Button: TNavigateBtn);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure confTrasacao;
    procedure transferencia(tabela: TtabelaType; codI: integer = 0; codF: integer = 0);
    procedure trimAppMemorySize;
    function LoadImage(AImage: TImage; ABlobField: TBlobField): Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{ TForm1 }

procedure TForm1.confTrasacao;
begin

  with fdtPg do
  begin

    if not Active then
      StartTransaction;

    commit;
  end;

end;

procedure TForm1.sbtnAnosClick(Sender: TObject);
begin
  transferencia(tblAnos);
end;

procedure TForm1.transformarImgFbPg(Sender: TObject);
var
  queryFb:       TFDQuery;
  queryPg:       TFDQuery;
  streamFoto1:   TStream;
  streamFoto2:   TStream;
  cod:           integer;
  dt1, dt2, dtt: TDateTime;
begin

  dt1           := now;
  lblHI.Caption := formatdatetime('hh:nn:ss.zzz', dt1);

  for cod := 0 to 308000 do
  begin

    lblCod.Caption := cod.ToString;

    queryPg := TFDQuery.Create(nil);
    queryFb := TFDQuery.Create(nil);
    try
      with queryFb do
      begin
        Connection := fdcFBVendaM;

        close;
        sql.Clear;

        sql.add('select * from fotos');
        sql.add('where codigo = :cod');

        ParamByName('cod').AsInteger := cod;

        open;
        first;
      end;

      if not queryFb.eof then
      begin

        with queryFb do
        begin

          if not FieldByName('foto1').IsNull then
            streamFoto1 := CreateBlobStream(FieldByName('foto1'), bmRead);

          if not FieldByName('foto2').IsNull then
            streamFoto2 := CreateBlobStream(FieldByName('foto2'), bmRead);

        end;

        with queryPg do
        begin
          Connection := fdcPgVendaM;

          close;
          sql.Clear;

          sql.add('delete from fotos');
          sql.add('where codigo = :cod');

          ParamByName('cod').AsInteger := cod;

          ExecSQL;
          confTrasacao;

          if (not queryFb.FieldByName('foto1').IsNull) or (not queryFb.FieldByName('foto1').IsNull)
          then
          begin

            close;
            sql.Clear;

            sql.add(' insert into fotos(codigo   ');

            if not queryFb.FieldByName('foto1').IsNull then
              sql.add(', foto1 ');

            if not queryFb.FieldByName('foto2').IsNull then
              sql.add(', foto2 ');

            sql.add(' ) values( :codigo   ');

            if not queryFb.FieldByName('foto1').IsNull then
              sql.add(', :foto1 ');

            if not queryFb.FieldByName('foto2').IsNull then
              sql.add(', :foto2 ');

            sql.add(' ) ');

            ParamByName('codigo').AsInteger := cod;

            if not queryFb.FieldByName('foto1').IsNull then
              ParamByName('foto1').LoadFromStream(streamFoto1, ftBlob);

            if not queryFb.FieldByName('foto2').IsNull then
              ParamByName('foto2').LoadFromStream(streamFoto2, ftBlob);

            ExecSQL;

            freeAndNil(streamFoto1);
            freeAndNil(streamFoto2);
          end;

        end;
      end;
    finally
      queryFb.close;
      queryPg.close;

      freeAndNil(queryFb);
      freeAndNil(queryPg);

      confTrasacao;
      trimAppMemorySize;

    end;

  end;

  dt2           := now;
  lblHF.Caption := formatdatetime('hh:nn:ss.zzz', dt2);

  dtt := dt2 - dt1;

  lblTotal.Caption := formatdatetime('hh:nn:ss.zzz', dtt);

end;

procedure TForm1.FormShow(Sender: TObject);
begin
  fdqProdutos.Active := true;
end;

function TForm1.LoadImage(AImage: TImage; ABlobField: TBlobField): Boolean;
var
  JpgImg: TPicture;
  StMem:  TMemoryStream;
begin
  if ABlobField.DataSet.IsEmpty then
  begin
    Result := False;
    Exit;
  end;

  AImage.Picture.Assign(nil);
  if not(ABlobField.IsNull) and not(ABlobField.AsString = '') then
  begin
    JpgImg := TPicture.Create;
    StMem  := TMemoryStream.Create;
    try
      ABlobField.SaveToStream(StMem);
      StMem.Position := 0;
      JpgImg.LoadFromStream(StMem);
      AImage.Picture.Assign(JpgImg);
    finally
      StMem.Free;
      JpgImg.Free;
    end;
  end;
  Result := true;
end;

procedure TForm1.sbtnCombustiveisClick(Sender: TObject);
begin
  transferencia(tblCombustiveis);
end;

procedure TForm1.sbtnMarcasClick(Sender: TObject);
begin
  transferencia(tblMarcas);
end;

procedure TForm1.sbtnModelosClick(Sender: TObject);
begin
  transferencia(tblModelos);
end;

procedure TForm1.sbtnMontadorasClick(Sender: TObject);
begin
  transferencia(tblMontadoras);
end;

procedure TForm1.sbtnMotoresClick(Sender: TObject);
begin
  transferencia(tblMotores);
end;

procedure TForm1.sbtnProdutosClick(Sender: TObject);
begin
  transferencia(tblProdutos);
end;

procedure TForm1.sbtnSegementosClick(Sender: TObject);
begin
  transferencia(tblSegmentos);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  queryPg:                        TFDQuery;
  streamFotoBck1, streamFotoBck2: TStream;
  streamFoto1, streamFoto2:       TStream;
  idft1, idft2:                   integer;
begin

  imgFotoBck1.Picture  := nil;
  imgFotoBck2.Picture  := nil;
  imgFoto1.Picture     := nil;
  imgFoto2.Picture     := nil;
  lblDescricao.Caption := '';

  queryPg := TFDQuery.Create(nil);

  try
    with queryPg do
    begin
      Connection := fdcPgVendaM;

      idft1 := 0;
      idft2 := 0;

      close;
      sql.Clear;

      sql.add('select foto1, foto2, referencia from produtos');
      sql.add('where codigo = :cod');

      ParamByName('cod').AsInteger := StrToInt(edtCodigo.Text);

      open;
      first;

      if not eof then
      begin
        lblDescricao.Caption := FieldByName('referencia').AsString;
        idft1                := FieldByName('foto1').AsInteger;
        idft2                := FieldByName('foto2').AsInteger;

        close;
        sql.Clear;

        sql.add('select * from fotosbck');
        sql.add('where codigo = :cod');

        ParamByName('cod').AsInteger := StrToInt(edtCodigo.Text);

        open;
        first;

        if not eof then
        begin

          if not FieldByName('foto1').IsNull then
          begin

            streamFotoBck1 := CreateBlobStream(FieldByName('foto1'), bmRead);

            if (streamFotoBck1.Size > 0) then
              imgFotoBck1.Picture.LoadFromStream(streamFotoBck1);

            freeAndNil(streamFotoBck1);

          end;

          if not FieldByName('foto2').IsNull then
          begin

            streamFotoBck2 := CreateBlobStream(FieldByName('foto2'), bmRead);

            if (streamFotoBck2.Size > 0) then
              imgFotoBck2.Picture.LoadFromStream(streamFotoBck2);

            freeAndNil(streamFotoBck2);
          end;

          { nota tabela }
          close;
          sql.Clear;

          sql.add('select foto from fotos ');
          sql.add('where id = :id         ');

          ParamByName('id').AsInteger := idft1;

          open;
          first;

          if not eof then
            if not FieldByName('foto').IsNull then
            begin

              streamFoto1 := CreateBlobStream(FieldByName('foto'), bmRead);

              if (streamFoto1.Size > 0) then
                imgFoto1.Picture.LoadFromStream(streamFoto1);

              freeAndNil(streamFoto1);
            end;

          close;
          sql.Clear;

          sql.add('select foto from fotos ');
          sql.add('where id = :id         ');

          ParamByName('id').AsInteger := idft2;

          open;
          first;

          if not eof then
            if not FieldByName('foto').IsNull then
            begin

              streamFoto2 := CreateBlobStream(FieldByName('foto'), bmRead);

              if (streamFoto2.Size > 0) then
                imgFoto2.Picture.LoadFromStream(streamFoto2);

              freeAndNil(streamFoto2);
            end;

        end;

      end;

    end;
  finally
    queryPg.close;

    freeAndNil(queryPg);
    trimAppMemorySize;

  end;

end;

procedure TForm1.stbnFotosClick(Sender: TObject);
var
  i, codI, codF: integer;
begin

  lblHI.Caption := formatdatetime('hh:nn:ss.zzz', now);

  for i := 0 to 650 do
  begin
    codI := 0;
    codF := 0;

    codI := i * 500;
    codF := codI + 499;

    lblCodInicial.Caption := codI.ToString;
    lblCodFinal.Caption   := codF.ToString;

    transferencia(tblFotos, codI, codF);
    trimAppMemorySize;
  end;

  lblHF.Caption := formatdatetime('hh:nn:ss.zzz', now);

end;

procedure TForm1.transferencia(tabela: TtabelaType; codI: integer = 0; codF: integer = 0);
var
  queryFb: TFDQuery;
  queryPg: TFDQuery;
begin

  try
    queryFb := TFDQuery.Create(nil);
    queryPg := TFDQuery.Create(nil);

    with queryFb do
    begin
      Connection := fdcFBVendaM;
      close;
      sql.Clear;

      case tabela of
        tblAnos:
          begin

            sql.add('select a.codigo, a.deletado, a.datacadastrado, a.dataalterado,');
            sql.add(' a.datadeletado, a.colaborador, a.datainicial, a.datafinal,   ');
            sql.add(' a.padraoantigo, coalesce(a.complemento,'''') as complemento  ');
            sql.add(' from anos a                                                  ');

          end;
        tblCombustiveis:
          begin

            sql.add('select c.codigo, c.descricao, c.deletado, c.datacadastrado,   ');
            sql.add('c.dataalterado, c.datadeletado, coalesce(c.complemento, '''') ');
            sql.add(' as complemento from combustiveis c                           ');

          end;

        tblFotos:
          begin

            sql.add('select f.codigo, f.foto1, f.foto2 from fotos f      ');
            sql.add('where (not f.foto1 is null or  not f.foto2 is null) ');

            if codF > 0 then
              sql.add('  and codigo between :codI and :codF              ');
            sql.add('order by codigo                                     ');

            if codF > 0 then
            begin
              ParamByName('codI').AsInteger := codI;
              ParamByName('codF').AsInteger := codF;
            end;

          end;
        tblMarcas:
          begin

            sql.add('select m.codigo, m.descricao, m.deletado, m.datacadastrado,   ');
            sql.add(' m.dataalterado, m.datadeletado, coalesce(m.complemento,'''') ');
            sql.add(' as complemento from marcas m                                 ');

          end;
        tblModelos:
          begin

            sql.add('select m.codigo, m.descricao, m.deletado, m.datacadastrado,   ');
            sql.add(' m.dataalterado, m.datadeletado, coalesce(m.complemento,'''') ');
            sql.add(' as complemento, m.montadora, m.datainicial, m.datafinal      ');
            sql.add(' from modelos m                                               ');

          end;
        tblMontadoras:
          begin

            sql.add('select m.codigo, m.descricao, m.deletado, m.datacadastrado,   ');
            sql.add(' m.dataalterado, m.datadeletado, coalesce(m.complemento,'''') ');
            sql.add(' as complemento from montadoras m                             ');

          end;
        tblMotores:
          begin

            sql.add('select m.codigo, m.descricao, m.deletado, m.datacadastrado,   ');
            sql.add(' m.dataalterado, m.datadeletado, coalesce(m.complemento,'''') ');
            sql.add(' as complemento from motores m                             ');

          end;
        tblSegmentos:
          begin

            sql.add('select m.codigo, m.descricao, m.deletado, m.datacadastrado,   ');
            sql.add(' m.dataalterado, m.datadeletado, coalesce(m.complemento,'''') ');
            sql.add(' as complemento from segmentos m                              ');

          end;
        tblProdutos:
          begin

            sql.add('select p.codigo, p.referencia, p.marca, p.categoria, p.montadora, p.motor,     ');
            sql.add('p.injecao, p.segmento, p.familia, p.modelo, p.datacadastro, p.dataalteracao,   ');
            sql.add('p.ano, p.combustivel, p.versao, p.versaomotor, coalesce(p.observacoes,'''') as ');
            sql.add('observacoes, p.deletado, p.datadeletado from produtos p                        ');

          end;
      end;

      open;
      first;

    end;

    with queryPg do
    begin
      Connection  := fdcPgVendaM;
      Transaction := fdtPg;
      close;
      sql.Clear;

      if codI = 0 then
      begin
        case tabela of
          tblAnos:
            sql.add('delete from anos ');
          tblCombustiveis:
            sql.add('delete from combustiveis ');
          tblFotos:
            sql.add('delete from fotos ');
          tblMarcas:
            sql.add('delete from marcas ');
          tblModelos:
            sql.add('delete from modelos ');
          tblMontadoras:
            sql.add('delete from montadoras ');
          tblMotores:
            sql.add('delete from motores ');
          tblSegmentos:
            sql.add('delete from segmentos ');
          tblProdutos:
            sql.add('delete from produtos ');
        end;

        ExecSQL;

        confTrasacao;
      end;

      while not queryFb.eof do
      begin

        case tabela of
          tblAnos:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO anos(codigo, deletado, datacadastrado, dataalterado,');
              sql.add('datadeletado, colaborador, datainicial, datafinal)  ');
              sql.add('VALUES (:codigo, :deletado, :datacadastrado, :dataalterado, ');
              sql.add(':datadeletado, :colaborador, :datainicial, :datafinal);');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;
              ParamByName('colaborador').AsInteger := queryFb.FieldByName('colaborador').AsInteger;
              ParamByName('datainicial').AsInteger := queryFb.FieldByName('datainicial').AsInteger;
              ParamByName('datafinal').AsInteger   := queryFb.FieldByName('datafinal').AsInteger;

            end;
          tblCombustiveis:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO combustiveis(codigo, descricao, deletado, datacadastrado, dataalterado,');
              sql.add('datadeletado)                                                         ');
              sql.add('VALUES (:codigo, :descricao, :deletado, :datacadastrado, :dataalterado,            ');
              sql.add(':datadeletado);                                                      ');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('descricao').AsString := queryFb.FieldByName('descricao').AsString;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;

            end;
          tblFotos:
            begin
              close;
              sql.Clear;

              sql.add(' insert into fotos(codigo ');

              if not queryFb.FieldByName('foto1').IsNull then
                sql.add(' ,  foto1              ');

              if not queryFb.FieldByName('foto2').IsNull then
                sql.add(' ,  foto2              ');

              sql.add(' ) values( :codigo        ');

              if not queryFb.FieldByName('foto1').IsNull then
                sql.add(' , :foto1              ');

              if not queryFb.FieldByName('foto2').IsNull then
                sql.add(' , :foto2              ');

              sql.add(' )');

              ParamByName('codigo').AsInteger := queryFb.FieldByName('codigo').AsInteger;

              if not queryFb.FieldByName('foto1').IsNull then
                ParamByName('foto1').AsVarByteStr := queryFb.FieldByName('foto1').AsVariant;

              if not queryFb.FieldByName('foto2').IsNull then
                ParamByName('foto2').AsVarByteStr := queryFb.FieldByName('foto2').AsVariant;

            end;
          tblMarcas:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO marcas(codigo, descricao, deletado, datacadastrado, dataalterado,      ');
              sql.add('datadeletado)                                                         ');
              sql.add('VALUES (:codigo, :descricao, :deletado, :datacadastrado, :dataalterado,            ');
              sql.add(':datadeletado);                                                      ');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('descricao').AsString := queryFb.FieldByName('descricao').AsString;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;

            end;
          tblModelos:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO modelos(codigo, descricao, deletado, datacadastrado, dataalterado,  ');
              sql.add('datadeletado, montadora, datainicial, datafinal )                               ');
              sql.add('VALUES (:codigo, :descricao, :deletado, :datacadastrado, :dataalterado,         ');
              sql.add(':datadeletado, :montadora, :datainicial, :datafinal );                          ');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('descricao').AsString := queryFb.FieldByName('descricao').AsString;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;
              ParamByName('montadora').AsInteger   := queryFb.FieldByName('montadora').AsInteger;
              ParamByName('datainicial').AsInteger := queryFb.FieldByName('datainicial').AsInteger;
              ParamByName('datafinal').AsInteger   := queryFb.FieldByName('datafinal').AsInteger;

            end;
          tblMontadoras:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO montadoras(codigo, descricao, deletado, datacadastrado, dataalterado,  ');
              sql.add('datadeletado )                                                                     ');
              sql.add('VALUES (:codigo, :descricao, :deletado, :datacadastrado, :dataalterado,            ');
              sql.add(':datadeletado );                                                                   ');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('descricao').AsString := queryFb.FieldByName('descricao').AsString;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;

            end;

          tblMotores:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO motores(codigo, descricao, deletado, datacadastrado, dataalterado,  ');
              sql.add('datadeletado)                                                                   ');
              sql.add('VALUES (:codigo, :descricao, :deletado, :datacadastrado, :dataalterado,         ');
              sql.add(':datadeletado);                                                                 ');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('descricao').AsString := queryFb.FieldByName('descricao').AsString;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;

            end;
          tblSegmentos:
            begin
              close;
              sql.Clear;

              sql.add('INSERT INTO segmentos(codigo, descricao, deletado, datacadastrado, dataalterado,');
              sql.add('datadeletado)                                                                   ');
              sql.add('VALUES (:codigo, :descricao, :deletado, :datacadastrado, :dataalterado,         ');
              sql.add(':datadeletado );                                                                ');

              ParamByName('codigo').AsInteger   := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('descricao').AsString := queryFb.FieldByName('descricao').AsString;
              ParamByName('deletado').AsInteger := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datacadastrado').AsDateTime := queryFb.FieldByName('datacadastrado')
                .AsDateTime;
              ParamByName('dataalterado').AsDateTime := queryFb.FieldByName('dataalterado')
                .AsDateTime;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;

            end;
          tblProdutos:
            begin
              close;
              sql.Clear;

              sql.add(' INSERT INTO public.produtos( codigo, referencia, marca, categoria, montadora,   ');
              sql.add(' motor, injecao, segmento, familia, modelo, datacadastro, dataalteracao, ano,    ');
              sql.add(' combustivel, versao, versaomotor, observacoes, deletado, datadeletado)          ');
              sql.add(' VALUES (:codigo, :referencia, :marca, :categoria, :montadora, :motor, :injecao, ');
              sql.add(' :segmento, :familia, :modelo, :datacadastro, :dataalteracao, :ano, :combustivel,');
              sql.add(' :versao, :versaomotor, :observacoes, :deletado, :datadeletado);                 ');

              ParamByName('codigo').AsInteger        := queryFb.FieldByName('codigo').AsInteger;
              ParamByName('referencia').AsString     := queryFb.FieldByName('referencia').AsString;
              ParamByName('marca').AsInteger         := queryFb.FieldByName('marca').AsInteger;
              ParamByName('categoria').AsInteger     := queryFb.FieldByName('categoria').AsInteger;
              ParamByName('montadora').AsInteger     := queryFb.FieldByName('montadora').AsInteger;
              ParamByName('motor').AsInteger         := queryFb.FieldByName('motor').AsInteger;
              ParamByName('injecao').AsInteger       := queryFb.FieldByName('injecao').AsInteger;
              ParamByName('segmento').AsInteger      := queryFb.FieldByName('segmento').AsInteger;
              ParamByName('familia').AsInteger       := queryFb.FieldByName('familia').AsInteger;
              ParamByName('modelo').AsInteger        := queryFb.FieldByName('modelo').AsInteger;
              ParamByName('datacadastro').AsDateTime := queryFb.FieldByName('datacadastro')
                .AsDateTime;
              ParamByName('dataalteracao').AsDateTime := queryFb.FieldByName('dataalteracao')
                .AsDateTime;
              ParamByName('ano').AsInteger         := queryFb.FieldByName('ano').AsInteger;
              ParamByName('combustivel').AsInteger := queryFb.FieldByName('combustivel').AsInteger;
              ParamByName('versao').AsInteger      := queryFb.FieldByName('versao').AsInteger;
              ParamByName('versaomotor').AsInteger := queryFb.FieldByName('versaomotor').AsInteger;
              ParamByName('observacoes').AsString  := queryFb.FieldByName('observacoes').AsString;
              ParamByName('deletado').AsInteger    := queryFb.FieldByName('deletado').AsInteger;
              ParamByName('datadeletado').AsDateTime := queryFb.FieldByName('datadeletado')
                .AsDateTime;

            end;
        end;

        ExecSQL;
        confTrasacao;

        queryFb.Next;
      end;

    end;

  finally
    confTrasacao;

    queryFb.close;
    queryPg.close;

    freeAndNil(queryFb);
    freeAndNil(queryPg);
  end;

  // if (codF = 0) or (codF = 325499) then
  // showMessage('Finalizado');

end;

procedure TForm1.trimAppMemorySize;
var
  MainHandle: THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessID);
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF);
    CloseHandle(MainHandle);
  except
  end;
  Application.ProcessMessages;

end;

procedure TForm1.xndbProdutosClick(Sender: TObject; Button: TNavigateBtn);
begin

  edtCodigo.Text := xndbProdutos.DataSource.DataSet.FieldByName('codigo').AsString;

  SpeedButton1Click(SpeedButton1);
end;

end.
