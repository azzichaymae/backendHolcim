import { defineStore } from "pinia";
import api from "@/services/api";

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: JSON.parse(localStorage.getItem("user")) || null,
        token: localStorage.getItem("token") || null,
        tokenTimestamp: localStorage.getItem('tokenTimestamp') || null,
    }),

    getters: {
        isAuthenticated: (state) => !!state.token,
        isRRH: (state) => state.user?.role === "RRH",
        isRH: (state) => state.user?.role === "RH",
        isManager: (state) => state.user?.role === "Manager",
    },

    actions: {
        async login(credentials) {
            const { data } = await api.post("/auth/login", credentials);

            this.token = data.token;
            this.user = data.user;
            this.tokenTimestamp = Date.now(); // Set timestamp

            localStorage.setItem("token", data.token);
            localStorage.setItem("user", JSON.stringify(data.user));
            localStorage.setItem("tokenTimestamp", this.tokenTimestamp.toString());
        },

        async logout() {
            await api.post("/auth/logout");
            this.tokenTimestamp = null;
            this.token = null;
            this.user = null;
            localStorage.removeItem("token");
            localStorage.removeItem("user");
             localStorage.removeItem('tokenTimestamp');
        },
initTabExpiryCheck() {
     
    const handleVisibilityChange = () => {
         
        if (!document.hidden && this.token) {
            const timestamp = localStorage.getItem('tokenTimestamp');
             
            if (timestamp) {
                const age = Date.now() - parseInt(timestamp);
                const maxAge = 15 * 60 * 1000;
                 
                if (age > maxAge) {
                     this.logout();
                    window.location.href = '/login';
                }  
            }
        }
    };
    
    document.addEventListener('visibilitychange', handleVisibilityChange);
     
    return () => {
        document.removeEventListener('visibilitychange', handleVisibilityChange);
     };
}
    },  
});
