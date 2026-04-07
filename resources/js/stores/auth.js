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
    console.log('[Auth] Initializing tab expiry check');
    
    const handleVisibilityChange = () => {
        console.log('[Auth] Visibility changed. Hidden:', document.hidden);
        console.log('[Auth] Has token:', !!this.token);
        
        if (!document.hidden && this.token) {
            const timestamp = localStorage.getItem('tokenTimestamp');
            console.log('[Auth] Token timestamp:', timestamp);
            
            if (timestamp) {
                const age = Date.now() - parseInt(timestamp);
                const maxAge = 15 * 60 * 1000;
                console.log(`[Auth] Token age: ${age}ms (${age/60000} minutes)`);
                console.log(`[Auth] Max age: ${maxAge}ms (${maxAge/60000} minutes)`);
                
                if (age > maxAge) {
                    console.log('[Auth] TOKEN EXPIRED! Logging out...');
                    this.logout();
                    window.location.href = '/login';
                } else {
                    console.log('[Auth] Token still valid');
                }
            }
        }
    };
    
    document.addEventListener('visibilitychange', handleVisibilityChange);
    console.log('[Auth] Event listener added');
    
    return () => {
        document.removeEventListener('visibilitychange', handleVisibilityChange);
        console.log('[Auth] Event listener removed');
    };
}
    },  
});
