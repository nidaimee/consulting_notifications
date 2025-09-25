// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "controllers"
import Rails from "@rails/ujs"
Rails.start()
import "tailadmin/dist/tailadmin.css";
import "tailadmin/dist/tailadmin.js";
import Sortable from "sortablejs";

document.addEventListener('DOMContentLoaded', () => {
  const list = document.getElementById('diets-list');
  if (list) {
    Sortable.create(list, {
      animation: 150,
      draggable: ".diet-card",
      onEnd: function(evt) {
        const order = Array.from(list.children).map((el, idx) => ({
          id: el.dataset.id,
          position: idx + 1
        }));

        fetch(list.dataset.reorderUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
          },
          body: JSON.stringify({ order })
        }).then(resp => resp.json())
          .then(data => {
            if (data.success) {
              // Sucesso! Pode mostrar mensagem
            } else {
              alert(data.message || "Erro ao salvar ordem");
            }
          });
      }
    });
  }
});