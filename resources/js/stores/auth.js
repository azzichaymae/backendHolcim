import { defineStore } from 'pinia';
import api             from '@/services/api';

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user:  JSON.parse(localStorage.getItem('user'))  || null,
        token: localStorage.getItem('token') || null,
    }),

    getters: {
        isAuthenticated: state => !!state.token,
        isRRH:     state => state.user?.role === 'RRH',
        isRH:      state => state.user?.role === 'RH',
        isManager: state => state.user?.role === 'Manager',
    },

    actions: {
        async login(credentials) {
            const { data } = await api.post('/auth/login', credentials);

            this.token = data.token;
            this.user  = data.user;

            localStorage.setItem('token', data.token);
            localStorage.setItem('user',  JSON.stringify(data.user));
        },

        async logout() {
            await api.post('/auth/logout');
            this.token = null;
            this.user  = null;
            localStorage.removeItem('token');
            localStorage.removeItem('user');
        },
    },
});