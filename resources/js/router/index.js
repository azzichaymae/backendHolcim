import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "@/stores/auth";

// Layouts
import AppLayout from "@/components/layouts/AppLayout.vue";

// Pages
import Login from "@/components/auth/Login.vue";
import Dashboard from "@/components/dashboard/Dashboard.vue";
import EmployeeList from "@/components/employees/EmployeeList.vue";
import EmployeeForm from "@/components/employees/EmployeeForm.vue";
import AttributionForm from "@/components/attributions/AttributionForm.vue";
import DocumentGeneration from "@/components/documents/DocumentGeneration.vue";
import AlertList from "@/components/alerts/AlertList.vue";
import Settings from "@/components/settings/Settings.vue";
import VoletList from "@/components/volets/VoletList.vue";
import Profile from "../components/profile/Profile.vue";
import Attributions from "../components/attributions/Attributions.vue";
import Referentiel from "../components/habilitations/Referentiel.vue";

const routes = [
    // Public
    { path: "/login", component: Login, name: "login" },

    // Protected — wrapped in AppLayout
    {
        path: "/",
        component: AppLayout,
        meta: { requiresAuth: true },
        children: [
            { path: "", redirect: "/dashboard" },
            { path: "dashboard", component: Dashboard, name: "dashboard" },
            { path: "employees", component: EmployeeList, name: "employees" },
            {
                path: "employees/create",
                component: EmployeeForm,
                name: "employees.create",
            },
            {
                path: "employees/:id/edit",
                component: EmployeeForm,
                name: "employees.edit",
            },

            {
                path: "attributions",
                component:Attributions,
                name: "attributions",
            },
            {
                path: "attributions/create",
                component: AttributionForm,
                name: "attributions.create",
            },
            {
                path: "documents",
                component: DocumentGeneration,
                name: "documents",
            },
            {
                path: "documents/:id",
                component: DocumentGeneration,
                name: "documents.id",
            },
                      { path: "alerts", component: AlertList, name: "alerts" },
            {
                path: "parametres",
                component: Settings,
                name: "parametres",
                meta: { roles: ["RRH"] },
            },
            { path: "volets", component: VoletList, name: "volets" },

            { path: "profile", component: Profile, name: "profile" },
            { path: 'referentiel', component: Referentiel, name: 'referentiel' }
        ],
    },

    // Catch all — redirect to dashboard
    { path: "/:pathMatch(.*)*", redirect: "/dashboard" },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

// Navigation guard
router.beforeEach((to, from, next) => {
    const auth = useAuthStore();

    if (to.meta.requiresAuth && !auth.isAuthenticated) {
        return next({ name: "login" });
    }

    if (to.meta.roles && !to.meta.roles.includes(auth.user?.role)) {
        return next({ name: "dashboard" });
    }

    next();
});

export default router;
