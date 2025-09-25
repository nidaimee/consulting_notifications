import Sortable from 'sortablejs';

document.addEventListener('DOMContentLoaded', () => {
  const list = document.getElementById('diets-list');
  if (list) {
    const grid = list.querySelector('.grid');
    const reorderUrl = list.dataset.reorderUrl;

    Sortable.create(grid, {
      animation: 150,
      handle: '.diet-card', // ou ajuste para o elemento que deseja arrastar
      onEnd: function(evt) {
        const order = Array.from(grid.children).map((el, idx) => ({
          id: el.dataset.id,
          position: idx + 1
        }));

        fetch(reorderUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': Rails.csrfToken() },
          body: JSON.stringify({ order })
        });
      }
    });
  }
});