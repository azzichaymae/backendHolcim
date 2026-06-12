import axios from "axios";

const api = axios.create({
    // api.js
    baseURL: import.meta.env.VITE_API_URL ?? "http://172.16.16.224/api",
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

// Attach token automatically to every request

api.interceptors.request.use((config) => {
    const token = localStorage.getItem("token");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

let  isRedirecting = false;
api.interceptors.response.use(
    response => response,
    error => {
        if (error.response?.status === 401) {
            if (!isRedirecting) {
                isRedirecting = true;
                localStorage.removeItem('token');
                window.location.href = '/login';
            }
        }
        return Promise.reject(error);
    }
);

export default api;
