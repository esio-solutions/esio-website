// Klaro Cookie Consent Configuration
// Documentation: https://klaro.org/docs/

window.klaroConfig = {
    version: 1,

    elementID: 'klaro',

    storageMethod: 'cookie',
    storageName: 'klaro',

    cookieDomain: '',
    cookieExpiresAfterDays: 365,

    privacyPolicy: '/legal/cookies/',

    default: true,
    mustConsent: true,
    acceptAll: true,
    hideDeclineAll: false,
    hideLearnMore: false,
    disablePoweredBy: true,

    translations: {
        en: {
            consentModal: {
                title: 'Help us improve ESIO',
                description: "We use a small amount of analytics to understand which parts of the site are useful and where to invest our time. No ads, no tracking across other sites — just anonymous usage data.",
            },
            consentNotice: {
                title: 'Cookies on ESIO',
                description: "We use cookies for anonymous usage analytics. Your consent helps us prioritise what to build next.",
                learnMore: 'Learn more',
                changeDescription: 'There were changes since your last visit, please update your consent.',
            },
            ok: 'Accept',
            save: 'Save',
            decline: 'No thanks',
            close: 'Close',
            acceptAll: 'Accept',
            acceptSelected: 'Accept selected',
            purposes: {
                analytics: {
                    title: 'Analytics',
                    description: 'Helps us see which pages are useful so we can improve the product and the site.',
                },
            },
            microsoftClarity: {
                title: 'Microsoft Clarity',
                description: 'Anonymous usage analytics and session replay. Helps us see how visitors interact with the site so we can fix usability issues.',
            },
        },
    },

    services: [
        {
            name: 'microsoftClarity',
            title: 'Microsoft Clarity',
            purposes: ['analytics'],
            cookies: [
                /^_clck/,
                /^_clsk/,
                /^CLID/,
                /^ANONCHK/,
                /^MUID/,
                /^MR/,
                /^SM/,
            ],
            required: false,
            optOut: false,
            default: true,
            onlyOnce: false,
        },
    ],
};
