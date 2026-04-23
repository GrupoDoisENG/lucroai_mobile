// lib/viewmodels/insumo_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/insumo_model.dart';

class InsumoViewModel extends ChangeNotifier {
  // Estados da tela
  List<Insumo> insumos = [];
  bool isLoading = false;
  String errorMessage = '';

  // Função que será chamada quando a tela abrir
  Future<void> buscarInsumos() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners(); // Avisa a tela para mostrar o "carregando"

    try {
      // ---------------------------------------------------------
      // MOCK DA API: Simulando o tempo de resposta do servidor
      // Quando a API estiver pronta, você apagará este Future.delayed 
      // e colocará algo como: final response = await api.get('/insumos');
      // ---------------------------------------------------------
      await Future.delayed(const Duration(seconds: 2)); 

      insumos = [
        Insumo(id: '1', nome: 'Farinha de Trigo', quantidade: 5000, unidade: 'g', precoCusto: 18.90),
        Insumo(id: '2', nome: 'Açúcar Refinado', quantidade: 2000, unidade: 'g', precoCusto: 8.50),
        Insumo(id: '3', nome: 'Leite Integral', quantidade: 6000, unidade: 'ml', precoCusto: 29.90),
        Insumo(id: '4', nome: 'Ovos', quantidade: 30, unidade: 'un', precoCusto: 22.00),
        Insumo(id: '5', nome: 'Chocolate em Pó', quantidade: 1000, unidade: 'g', precoCusto: 14.90),
      ];
      
    } catch (e) {
      errorMessage = "Erro ao carregar os dados. Tente novamente.";
    } finally {
      isLoading = false;
      notifyListeners(); // Avisa a tela que acabou de carregar (com sucesso ou erro)
    }
  }

  // Função preparada para o modal de "Novo Insumo"
  Future<void> adicionarInsumo(Insumo novoInsumo) async {
    // Aqui você enviará o POST para a API no futuro.
    // Por enquanto, apenas adicionamos na lista local e atualizamos a tela.
    insumos.add(novoInsumo);
    notifyListeners();
  }

  void removerInsumo(String id) {
    // Procura na lista o insumo com o ID correspondente e remove
    insumos.removeWhere((insumo) => insumo.id == id);
    notifyListeners(); // Avisa a tela para se redesenhar sem esse item
  }
}