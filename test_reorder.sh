#!/bin/bash

# Script para testar o endpoint de reordenação
echo "Testando endpoint de reordenação..."

# Primeiro vamos verificar se o servidor está rodando
echo "Verificando se o servidor está rodando..."
curl -s http://localhost:3000 > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Servidor está rodando"
else
    echo "❌ Servidor não está rodando. Inicie com: rails server"
    exit 1
fi

# Teste básico do endpoint
echo "Testando endpoint..."
curl -X PATCH http://localhost:3000/diets/1/reorder_foods \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: test" \
  -d '{"order":[{"id":1,"position":1},{"id":2,"position":2}]}' \
  -v

echo -e "\n\nSe você ver um erro 422 (Unprocessable Entity), é normal - significa que o CSRF token não é válido"
echo "Se você ver um erro 404, verifique se a dieta com ID 1 existe"
echo "Se você ver um erro 500, há um problema no código do servidor"
