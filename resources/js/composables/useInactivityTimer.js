import { useAuthStore } from "@/stores/auth";
import { useRouter } from "vue-router";
import { ref } from "vue";

const TIMEOUT_MS = 15 * 60 * 1000; // 15 minutes — change as needed
const WARNING_MS = 14 * 60 * 1000; // warn at 14 min

let timer = null;
let warningTimer = null;

export function useInactivityTimer() {
    const auth = useAuthStore();
    const router = useRouter();

    const events = [
        "mousemove",
        "mousedown",
        "keydown",
        "touchstart",
        "scroll",
        "click",
    ];

    const logout = () => {
        auth.logout();
        router.push("/login");
    };

    const showWarning = ref(false); 

    const reset = () => {
        clearTimeout(timer);
        clearTimeout(warningTimer);
        showWarning.value = false;

        warningTimer = setTimeout(() => {
            showWarning.value = true; // show banner
        }, WARNING_MS);

        timer = setTimeout(logout, TIMEOUT_MS);
    };

    const start = () => {
        events.forEach((e) =>
            window.addEventListener(e, reset, { passive: true }),
        );
        reset(); // start the first timer
    };

    const stop = () => {
        clearTimeout(timer);
        events.forEach((e) => window.removeEventListener(e, reset));
    };

    return { start, stop };
}
