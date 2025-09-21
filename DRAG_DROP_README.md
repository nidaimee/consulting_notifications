# Sistema de Drag & Drop para Dietas

## Funcionalidades Implementadas

### Reordenação de Alimentos
- **Drag & Drop moderno**: Clique e arraste qualquer linha de alimento para reordenar
- **Feedback visual**: Indicadores visuais durante o arraste
- **Atualizações em tempo real**: As posições são salvas automaticamente no servidor

### Interface do Usuário
- **Indicador de posição**: Círculo numerado mostra a ordem atual
- **Handle de arraste**: Ícone de pontos que aparece ao passar o mouse
- **Feedback visual**: 
  - Linha fica translúcida durante o arraste
  - Indicador azul mostra onde o item será solto
  - Animação suave de transição

### Funcionalidades Técnicas
- **Persistência**: Posições são salvas no banco de dados
- **Transações seguras**: Operações de reordenação são atômicas
- **Fallback**: Botões de subir/descer ainda funcionam como backup
- **Notificações**: Feedback ao usuário sobre sucesso/erro das operações

## Como Usar

1. **Visualizar ordem atual**: Os números nos círculos azuis mostram a posição atual
2. **Reordenar por drag & drop**: 
   - Passe o mouse sobre uma linha de alimento
   - Clique e segure no ícone de pontos (handle)
   - Arraste para a nova posição
   - Solte para confirmar
3. **Reordenar por botões**: Use os botões ↑ ↓ como alternativa

## Estrutura Técnica

### Modelo (DietFood)
```ruby
# Campos
- position: integer (posição do alimento na dieta)

# Métodos
- move_up! / move_down! (mover com botões)
- first_position? / last_position? (verificar limites)
```

### Controller (DietsController)
```ruby
# Rota: PATCH /diets/:id/reorder_foods
def reorder_foods
  # Atualiza posições em batch via transação
  # Retorna JSON com status da operação
end
```

### JavaScript
- Event listeners para drag & drop
- Manipulação de DOM para reordenação visual
- Requisição AJAX para salvar no servidor
- Sistema de notificações elegante

## Tecnologias Utilizadas
- **Rails 8.0**: Backend e persistência
- **TailwindCSS**: Estilização moderna
- **JavaScript Vanilla**: Funcionalidade drag & drop
- **HTML5 Drag & Drop API**: Eventos nativos do navegador

## Compatibilidade
- Navegadores modernos com suporte a HTML5 Drag & Drop
- Funciona em desktop e tablets
- Fallback para botões em dispositivos sem suporte a drag & drop
