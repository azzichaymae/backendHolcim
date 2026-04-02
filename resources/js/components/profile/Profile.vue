<template>
  <div class="profile-page">

    <!-- ── Hero ───────────────────────────────────────── -->
    <div class="profile-hero">
      <!-- <div class="hero-banner"></div> -->
      <div class="hero-body">
        <div class="hero-left">
          <div class="avatar-ring">
            <div class="profile-avatar-lg">{{ initials }}</div>
          </div>
          <div class="hero-info">
            <h1 class="hero-name">{{ user?.nom }} {{ user?.prenom }}</h1>
            <div class="hero-meta">
              <span class="role-pill" :class="user?.role?.toLowerCase()">{{ user?.role }}</span>
              <span class="hero-service" v-if="user?.service?.nom ?? user?.service">
                <span class="dot-sep"></span>
                {{ user?.service?.nom ?? user?.service }}
              </span>
            </div>
          </div>
        </div>
        <div class="hero-right">
          <div class="hero-stat">
            <span class="stat-num">{{ user?.role }}</span>
            <span class="stat-lbl">Rôle actuel</span>
          </div>
          <div class="hero-stat-divider"></div>
          <div class="hero-stat">
            <span class="stat-num online">
              <span class="pulse-dot"></span> Active
            </span>
            <span class="stat-lbl">Session</span>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Cards grid ─────────────────────────────────── -->
    <div class="profile-grid">

      <!-- Personal info -->
      <div class="pcard">
        <div class="pcard-header">
          <div class="pcard-icon-wrap blue">
            <span v-html="icons.user"></span>
          </div>
          <div>
            <div class="pcard-title">Informations personnelles</div>
            <div class="pcard-sub">Détails de votre compte</div>
          </div>
        </div>
        <div class="info-rows">
          <div class="info-row">
            <span class="info-key">Nom complet</span>
            <span class="info-val">{{ user?.nom }} {{ user?.prenom }}</span>
          </div>
          <div class="info-row">
            <span class="info-key">Adresse email</span>
            <span class="info-val email-val">{{ user?.email }}</span>
          </div>
          <div class="info-row">
            <span class="info-key">Rôle</span>
            <span class="info-val">
              <span class="role-pill sm" :class="user?.role?.toLowerCase()">{{ user?.role }}</span>
            </span>
          </div>
          <div class="info-row">
            <span class="info-key">Service</span>
            <span class="info-val">{{ user?.service?.nom ?? user?.service ?? '—' }}</span>
          </div>
        </div>
      </div>

      <!-- Security -->
      <div class="pcard">
        <div class="pcard-header">
          <div class="pcard-icon-wrap green">
            <span v-html="icons.shield"></span>
          </div>
          <div>
            <div class="pcard-title">Sécurité</div>
            <div class="pcard-sub">Paramètres de connexion</div>
          </div>
        </div>
        <div class="info-rows">
          <div class="info-row">
            <span class="info-key">Mot de passe</span>
            <span class="info-val pwd-dots">••••••••••</span>
          </div>
          <div class="info-row">
            <span class="info-key">Session</span>
            <span class="info-val">
              <span class="badge-active">
                <span class="pulse-dot sm"></span>
                Active
              </span>
            </span>
          </div>
          <div class="info-row">
            <span class="info-key">Expiration</span>
            <span class="info-val">15 min d'inactivité</span>
          </div>
        </div>
        <button class="btn-change-pwd" @click="showPwdModal=true" :disabled="auth.user?.role !== 'RRH'">
          <span v-html="icons.key"></span>
          Changer le mot de passe
        </button>
      </div>

    </div>

    <!-- ── User management (RRH only) ─────────────────── -->
    <div class="pcard pcard-full" v-if="auth.user?.role === 'RRH'">
      <div class="pcard-header">
        <div class="pcard-icon-wrap orange">
          <span v-html="icons.users"></span>
        </div>
        <div>
          <div class="pcard-title">Gestion des utilisateurs</div>
          <div class="pcard-sub">{{ users.length }} utilisateur(s) enregistré(s)</div>
        </div>
        <button class="btn-add-user" @click="openUserModal()">
          <span v-html="icons.plus"></span>
          Ajouter
        </button>
      </div>

      <div class="state-box" v-if="loadingUsers">
        <div class="loader"></div>
      </div>

      <div class="state-box empty" v-else-if="users.length === 0">
        <span class="empty-icon" v-html="icons.usersEmpty"></span>
        <p>Aucun utilisateur trouvé.</p>
        <button class="btn-add-user" @click="openUserModal()">
          <span v-html="icons.plus"></span>
          Créer le premier utilisateur
        </button>
      </div>

      <div class="utbl-wrap" v-else>
        <table class="utbl">
          <thead>
            <tr>
              <th>Utilisateur</th>
              <th>Email</th>
              <th>Rôle</th>
              <th>Service</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in users" :key="u.id" class="utbl-row">
              <td>
                <div class="ucell">
                  <div class="u-avatar">
                    {{ ((u.prenom?.charAt(0) ?? '') + (u.nom?.charAt(0) ?? '')).toUpperCase() }}
                  </div>
                  <div class="u-name">{{ u.nom }} {{ u.prenom }}</div>
                </div>
              </td>
              <td class="td-muted">{{ u.email }}</td>
              <td>
                <span class="role-pill sm" :class="u.role?.toLowerCase()">{{ u.role }}</span>
              </td>
              <td class="td-muted">{{ u.service?.nom ?? '—' }}</td>
              <td>
                <div class="row-actions">
                  <button class="act-btn edit" @click="openUserModal(u)" title="Modifier">
                    <span v-html="icons.edit"></span>
                  </button>
                  <button class="act-btn del" @click="confirmDeleteUser(u)"
                    title="Supprimer" :disabled="u.id === auth.user?.id">
                    <span v-html="icons.trash"></span>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- ── Change password modal ───────────────────────── -->
    <Teleport to="body">
      <div v-if="showPwdModal" class="profile-modal-backdrop" @click.self="closePwdModal">
        <div class="modal-box">
          <div class="modal-top">
            <div class="modal-icon-wrap green">
              <span v-html="icons.key"></span>
            </div>
            <div>
              <div class="modal-title">Changer le mot de passe</div>
              <div class="modal-sub">Minimum 8 caractères</div>
            </div>
            <button class="modal-close" @click="closePwdModal">✕</button>
          </div>
          <div class="profile-modal-body">
            <div class="mfield">
              <label>Mot de passe actuel <span class="req">*</span></label>
              <input v-model="pwd.current" type="password" placeholder="••••••••" />
              <span class="err" v-if="pwdErrors.current">{{ pwdErrors.current }}</span>
            </div>
            <div class="mfield">
              <label>Nouveau mot de passe <span class="req">*</span></label>
              <input v-model="pwd.new" type="password" placeholder="••••••••" />
              <span class="err" v-if="pwdErrors.new">{{ pwdErrors.new }}</span>
            </div>
            <div class="mfield">
              <label>Confirmer le mot de passe <span class="req">*</span></label>
              <input v-model="pwd.confirm" type="password" placeholder="••••••••" />
              <span class="err" v-if="pwdErrors.confirm">{{ pwdErrors.confirm }}</span>
            </div>
          </div>
          <div class="alert success" v-if="pwdSuccess">✓ Mot de passe modifié avec succès.</div>
          <div class="alert error"   v-if="pwdErrors.global">{{ pwdErrors.global }}</div>
          <div class="profile-modal-footer">
            <button class="btn-ghost" @click="closePwdModal">Annuler</button>
            <button class="btn-primary" @click="changePasswordRRH" :disabled="changingPwd">
              <span class="btn-spinner" v-if="changingPwd"></span>
              Enregistrer
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Add / Edit user modal ───────────────────────── -->
    <Teleport to="body">
      <div v-if="showUserModal" class="profile-modal-backdrop" @click.self="closeUserModal">
        <div class="modal-box wide">
          <div class="modal-top">
            <div class="modal-icon-wrap blue">
              <span v-html="editUser ? icons.edit : icons.plus"></span>
            </div>
            <div>
              <div class="modal-title">
                {{ editUser ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur' }}
              </div>
              <div class="modal-sub">
                {{ editUser ? 'Mettre à jour les informations' : 'Créer un nouveau compte' }}
              </div>
            </div>
            <button class="modal-close" @click="closeUserModal">✕</button>
          </div>

          <div class="profile-modal-body">
            <div class="form-row-2">
              <div class="mfield">
                <label>Nom <span class="req">*</span></label>
                <input v-model="userForm.nom" type="text" placeholder="El Fassi" />
                <span class="err" v-if="userErrors.nom">{{ userErrors.nom }}</span>
              </div>
              <div class="mfield">
                <label>Prénom <span class="req">*</span></label>
                <input v-model="userForm.prenom" type="text" placeholder="Sara" />
                <span class="err" v-if="userErrors.prenom">{{ userErrors.prenom }}</span>
              </div>
            </div>
            <div class="mfield">
              <label>Email <span class="req">*</span></label>
              <input v-model="userForm.email" type="email" placeholder="s.elfassi@holcim.ma" />
              <span class="err" v-if="userErrors.email">{{ userErrors.email }}</span>
            </div>
            <div class="form-row-2">
              <div class="mfield">
                <label>Rôle <span class="req">*</span></label>
                <select v-model="userForm.role">
                  <option value="">Sélectionner</option>
                  <option value="RRH">RRH</option>
                  <option value="RH">RH</option>
                  <option value="Manager">Manager</option>
                </select>
                <span class="err" v-if="userErrors.role">{{ userErrors.role }}</span>
              </div>
              <div class="mfield">
                <label>Service</label>
                <select v-model="userForm.service_id">
                  <option value="">Aucun service</option>
                  <option v-for="s in services" :key="s.id" :value="s.id">{{ s.nom }}</option>
                </select>
              </div>
            </div>

            <template v-if="!editUser">
              <div class="section-divider"><span>Mot de passe</span></div>
              <div class="form-row-2">
                <div class="mfield">
                  <label>Mot de passe <span class="req">*</span></label>
                  <input v-model="userForm.password" type="password" placeholder="••••••••" />
                  <span class="err" v-if="userErrors.password">{{ userErrors.password }}</span>
                </div>
                <div class="mfield">
                  <label>Confirmer <span class="req">*</span></label>
                  <input v-model="userForm.password_confirmation" type="password" placeholder="••••••••" />
                  <span class="err" v-if="userErrors.password_confirmation">{{ userErrors.password_confirmation }}</span>
                </div>
              </div>
            </template>

            <template v-if="editUser">
              <div class="section-divider"><span>Réinitialisation du mot de passe</span></div>
              <label class="toggle-row">
                <input type="checkbox" v-model="resetPassword" />
                <span class="toggle-label">Changer le mot de passe</span>
              </label>
              <template v-if="resetPassword">
                <div class="form-row-2" style="margin-top:12px;">
                  <div class="mfield">
                    <label>Nouveau mot de passe</label>
                    <input v-model="userForm.password" type="password" placeholder="••••••••" />

                  </div>
                  <div class="mfield">
                    <label>Confirmer</label>
                    <input v-model="userForm.password_confirmation" type="password" placeholder="••••••••" />

                  </div>
                    <span class="err" v-if="userErrors.password">{{ userErrors.password }}</span>

                </div>
              </template>
            </template>
          </div>

          <div class="alert error" v-if="userErrors.global">{{ userErrors.global }}</div>
          <div class="profile-modal-footer">
            <button class="btn-ghost" @click="closeUserModal">Annuler</button>
            <button class="btn-primary" @click="submitUser" :disabled="savingUser">
              <span class="btn-spinner" v-if="savingUser"></span>
              {{ editUser ? 'Enregistrer' : 'Créer l\'utilisateur' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- ── Delete confirm ──────────────────────────────── -->
    <ConfirmModal
      :show="!!deleteUserTarget"
      title="Supprimer cet utilisateur ?"
      confirmLabel="Supprimer"
      :loading="deletingUser"
      :icon="icons.trash"
      @confirm="deleteUser"
      @cancel="deleteUserTarget = null"
    >
      Supprimer le compte de
      <strong>{{ deleteUserTarget?.nom }} {{ deleteUserTarget?.prenom }}</strong> ?<br>
      Cette action est irréversible.
    </ConfirmModal>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, reactive } from 'vue';
import api from '@/services/api';
import { useAuthStore } from '@/stores/auth';
import ConfirmModal from '@/components/shared/ConfirmModal.vue';
import '@/../css/components/profile/profile.css';

const auth = useAuthStore();
const user = ref(null);

const icons = {
  user:       `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>`,
  shield:     `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>`,
  key:        `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>`,
  users:      `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>`,
  usersEmpty: `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>`,
  plus:       `<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>`,
  edit:       `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>`,
  trash:      `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>`,
};

const initials = computed(() => {
  if (!user.value) return '?';
  console.log(user.value);
  return ((user.value.prenom?.charAt(0) ?? '') + (user.value.nom?.charAt(0) ?? '')).toUpperCase();
});

const fetchProfile = async () => {
  try { const { data } = await api.get('/auth/me'); user.value = data; }
  catch (e) { console.error(e); }
};

// Password
const showPwdModal = ref(false);
const changingPwd  = ref(false);
const pwdSuccess   = ref(false);
const pwd          = reactive({ current: '', new: '', confirm: '' });
const pwdErrors    = reactive({ current: '', new: '', confirm: '', global: '' });

const closePwdModal = () => {
  showPwdModal.value = false; 
  pwdSuccess.value = false;
  Object.assign(pwd, { current: '', new: '', confirm: '' });
  Object.keys(pwdErrors).forEach(k => pwdErrors[k] = '');
};
const changePasswordRRH = async () => {
  Object.keys(pwdErrors).forEach(k => pwdErrors[k] = '');
  pwdSuccess.value = false;
  if (!pwd.current) { pwdErrors.current = 'Obligatoire.'; return; }
  if (!pwd.new || pwd.new.length < 8) { pwdErrors.new = 'Minimum 8 caractères.'; return; }
  if (pwd.new !== pwd.confirm) { pwdErrors.confirm = 'Ne correspondent pas.'; return; }
  changingPwd.value = true;
  try {
    await api.put('/auth/change-password', {
      current_password:      pwd.current,
      password:              pwd.new,
      password_confirmation: pwd.confirm,
    });
    pwdSuccess.value = true;

    // ── Auto-close after 1.5 seconds ──────────────────
    setTimeout(() => closePwdModal(), 1000);

  } catch (err) {
    pwdErrors.global = err.response?.data?.message ?? 'Erreur.';
  } finally {
    changingPwd.value = false;
  }
};

// Users
const users = ref([]); const services = ref([]);
const loadingUsers = ref(false); const savingUser = ref(false);
const deletingUser = ref(false); const showUserModal = ref(false);
const editUser = ref(null); const deleteUserTarget = ref(null);
const resetPassword = ref(false);

const defaultUserForm = () => ({ nom: '', prenom: '', email: '', role: '', service_id: '', password: '', password_confirmation: '' });
const userForm   = reactive(defaultUserForm());
const userErrors = reactive({ nom: '', prenom: '', email: '', role: '', password: '', password_confirmation: '', global: '' });

const fetchUsers = async () => {
  loadingUsers.value = true;
  try {
    const [ur, sr] = await Promise.all([api.get('/users'), api.get('/services')]);
    users.value = ur.data; services.value = sr.data;
  } catch (e) { console.error(e); } finally { loadingUsers.value = false; }
};

const openUserModal = (u = null) => {
  editUser.value = u;
  resetPassword.value = false;
  Object.keys(userErrors).forEach(k => userErrors[k] = '');

  if (u) {
    const nom = u.nom;
    const prenom    = u.prenom;

    Object.assign(userForm, {
      nom,
      prenom,
      email:                 u.email,
      role:                  u.role,
      service_id:            u.service_id ?? '',
      password:              '',
      password_confirmation: '',
    });
  } else {
    Object.assign(userForm, defaultUserForm());
  }

  showUserModal.value = true;
};

const closeUserModal = () => { showUserModal.value = false; editUser.value = null; };

const validateUser = () => {
  let v = true; Object.keys(userErrors).forEach(k => userErrors[k] = '');
  if (!userForm.nom)    { userErrors.nom    = 'Obligatoire.'; v = false; }
  if (!userForm.prenom) { userErrors.prenom = 'Obligatoire.'; v = false; }
  if (!userForm.email)  { userErrors.email  = 'Obligatoire.'; v = false; }
  if (!userForm.role)   { userErrors.role   = 'Obligatoire.'; v = false; }
  if (!editUser.value) {
    if (!userForm.password || userForm.password.length < 8) { userErrors.password = 'Minimum 8 caractères.'; v = false; }
    if (userForm.password !== userForm.password_confirmation) { userErrors.password_confirmation = 'Ne correspondent pas.'; v = false; }
  }
  return v;
};

const submitUser = async () => {
  if (!validateUser()) return;
  savingUser.value = true;
  const payload = { nom: userForm.nom, prenom: userForm.prenom, email: userForm.email, role: userForm.role, service_id: userForm.service_id || null };
  if (!editUser.value || resetPassword.value) { payload.password = userForm.password; payload.password_confirmation = userForm.password_confirmation; }
  try {
    if (editUser.value) {
      const { data } = await api.put(`/users/${editUser.value.id}`, payload);
      const idx = users.value.findIndex(u => u.id === editUser.value.id);
      if (idx !== -1) users.value[idx] = data;
    } else {
      const { data } = await api.post('/users', payload);
      users.value.unshift(data);
    }
    closeUserModal();
  } catch (err) {
    const res = err.response?.data;
    if (res?.errors) Object.keys(res.errors).forEach(k => { if (k in userErrors) userErrors[k] = res.errors[k][0]; });
    else userErrors.global = res?.message ?? 'Une erreur est survenue.';
  } finally { savingUser.value = false; }
};

const confirmDeleteUser = (u) => { deleteUserTarget.value = u; };
const deleteUser = async () => {
  deletingUser.value = true;
  try {
    await api.delete(`/users/${deleteUserTarget.value.id}`);
    users.value = users.value.filter(u => u.id !== deleteUserTarget.value.id);
    deleteUserTarget.value = null;
  } catch (err) { alert(err.response?.data?.message ?? 'Impossible de supprimer.'); deleteUserTarget.value = null; }
  finally { deletingUser.value = false; }
};

onMounted(async () => {
  await fetchProfile();
  if (auth.user?.role === 'RRH') fetchUsers();
});
</script>

