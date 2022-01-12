import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minhasanotacoes/helper/AnotacaoHelper.dart';
import 'package:minhasanotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTelaCadastro({Anotacao anotacao}) {

    String textoSalvarAtualizar = "";
    if( anotacao == null ){//salvando
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    }else{//atualizar
      textoSalvarAtualizar = "Atualizar";
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
    }


    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título",
                      hintText: "Digite título..."
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição"
                  ),
                ),
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  //Salvar
                  _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                  Navigator.pop(context);
                },
                child: Text(textoSalvarAtualizar),

              ),
            ],
          );
        }
    );
  }

  _recuperarAnotacoes()  async {

List anotacoesRecuperadas = await _db.recuperarAnotacoes();

List<Anotacao> listaTemporaria = List<Anotacao>();
for (var item in anotacoesRecuperadas){

  Anotacao anotacao = Anotacao.fromMap(item);
  listaTemporaria.add(anotacao);

}
setState(() {
  _anotacoes = listaTemporaria;
});
listaTemporaria = null;

print("lista anotacoes: " + anotacoesRecuperadas.toString());

  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    //print("data atual: " + DateTime.now().toString());

    if (anotacaoSelecionada == null){//salvar
 Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
 int resultado = await _db.salvarAnotacao(anotacao);

    }else{//atualizar

      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);

    }

   //print("salvar anotacao: " + resultado.toString());
    _tituloController.clear();
    _descricaoController.clear();
    _recuperarAnotacoes();
  }
  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
    print("id: $id");
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }
  _formatarData(String data){

initializeDateFormatting("pt_BR");
//var formatador = DateFormat("d/MM/y H:m:s");
var formatador = DateFormat.yMd("pt_BR");
DateTime dataConvertida = DateTime.parse(data);
String dataFormatada = formatador.format(dataConvertida);
return dataFormatada;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color (0xff2b2b2b),
      appBar: AppBar(
        title: Text("Anotações",
          style: TextStyle(
          color: Color (0xffffffff),
        ),
        ),
        backgroundColor: Color (0xff2b2b2b),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _anotacoes.length,
                  itemBuilder: (context, index){
                  final anotacao = _anotacoes[index];
                  return Card(
                    child: ListTile(
                      title: Text(anotacao.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color (0xff2b2b2b),
                        ),
                      ),
                      subtitle: Text("${_formatarData(anotacao.data)} - ${anotacao.descricao}",
                        style: TextStyle(
                        fontSize: 16,
                        color: Color (0xff2b2b2b),
                      ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              _exibirTelaCadastro(anotacao: anotacao);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 25),
                              child: Icon(Icons.edit, color: Color (0xff2b2b2b),),

                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              _removerAnotacao(anotacao.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Icon(Icons.remove_circle_outline, color: Color (0xff2b2b2b),),

                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  },

              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Color (0xff2b2b2b),
          child: Icon(Icons.add),
          onPressed: () {
            _exibirTelaCadastro();
          }
      ),
    );
  }
}

