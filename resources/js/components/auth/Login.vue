<template>
  <div class="login-page">

    <!-- Left Panel -->
    <div class="left-panel">
      <div class="brand">
        <div class="brand-title">HOLCIM SPIRIT</div>
        <div class="brand-sub">
          <span class="people">PEOPLE</span>
          <span class="performance">PERFORMANCE</span>
        </div>
        <div class="brand-tagline">growth starts within us</div>
      </div>
    </div>

    <!-- Right Panel -->
    <div class="right-panel">
      <div class="form-container">

        <div class="welcome">
          <h1>Bienvenue</h1>
          <p>Se connecter à votre compte pour continuer</p>
        </div>

        <form @submit.prevent="handleLogin">

          <!-- Email -->
          <div class="field">
            <label>Email</label>
            <input
              v-model="form.email"
              type="email"
              placeholder="email@holcim.ma"
              :class="{ 'input-error': errors.email }"
              autocomplete="email"
            />
            <span class="error-msg" v-if="errors.email">{{ errors.email }}</span>
          </div>

          <!-- Mot de passe -->
          <div class="field">
            <label>Mot de passe</label>
            <div class="password-wrapper">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="••••••••••••"
                :class="{ 'input-error': errors.password }"
                autocomplete="current-password"
              />
              <button type="button" class="toggle-pwd" @click="showPassword = !showPassword">
                <svg v-if="!showPassword" xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                </svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 4.411m0 0L21 21"/>
                </svg>
              </button>
            </div>
            <span class="error-msg" v-if="errors.password">{{ errors.password }}</span>
          </div>

          <!-- Remember me + forgot -->
          <div class="form-options">
            <label class="remember">
              <input type="checkbox" v-model="form.remember" />
              <span>Se souvenir de moi</span>
            </label>
            <a href="#" class="forgot">Mot de passe oublié ?</a>
          </div>

          <!-- Global error -->
          <div class="global-error" v-if="errors.global">
            {{ errors.global }}
          </div>

          <!-- Submit -->
          <button type="submit" class="btn-login" :disabled="loading">
            <span v-if="loading" class="spinner"></span>
            <span v-else>Se connecter</span>
          </button>

        </form>

        <div class="footer-text">
          © 2026 Holcim Factory Compliance Platform
        </div>

      </div>
    </div>

  </div>
</template>

<script setup>
import '@/../css/components/auth/login.css';
import { ref, reactive } from 'vue';
import { useRouter }     from 'vue-router';
import { useAuthStore }  from '@/stores/auth';

const router   = useRouter();
const authStore = useAuthStore();

const showPassword = ref(false);
const loading      = ref(false);

const form = reactive({
  email:    '',
  password: '',
  remember: false,
});

const errors = reactive({
  email:    '',
  password: '',
  global:   '',
});

const clearErrors = () => {
  errors.email    = '';
  errors.password = '';
  errors.global   = '';
};

const validate = () => {
  let valid = true;
  if (!form.email) {
    errors.email = 'L\'email est obligatoire.';
    valid = false;
  }
  if (!form.password) {
    errors.password = 'Le mot de passe est obligatoire.';
    valid = false;
  }
  return valid;
};

const handleLogin = async () => {
  clearErrors();
  if (!validate()) return;

  loading.value = true;
  try {
    await authStore.login({
      email:    form.email,
      password: form.password,
    });
    router.push({ name: 'dashboard' });
  } catch (err) {
    const data = err.response?.data;
    if (data?.errors?.email) {
      errors.email = data.errors.email[0];
    } else {
      errors.global = 'Identifiants incorrects. Veuillez réessayer.';
    }
  } finally {
    loading.value = false;
  }
};
</script>