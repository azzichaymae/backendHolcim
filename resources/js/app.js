import { createApp }    from 'vue';
import { createPinia }  from 'pinia';
import router           from './router';
import App              from './App.vue';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

 const app = createApp(App);

app.use(createPinia());
app.use(router);
app.mount('#app');
app.directive('click-outside', {
  mounted(el, binding) {
    el._clickOutside = (e) => { if (!el.contains(e.target)) binding.value(e); };
    document.addEventListener('click', el._clickOutside);
  },
  unmounted(el) { document.removeEventListener('click', el._clickOutside); }
});
