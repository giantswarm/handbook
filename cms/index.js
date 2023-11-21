// CMS init file for dev-test
CMS.init();

const stripQuotes = (str) => {
    let i = 0;
    for (; i < str.length && (str[i] === '"' || str[i] === '\''); ++i)
        ;
    let j = str.length;
    for (; j > 0 && (str[j-1] === '"' || str[j-1] === '\''); --j)
        ;
    return str.slice(i, j);
};

CMS.registerShortcode('relref', {
    label: 'Relref',
    openTag: '{{< ',
    closeTag: ' >}}',
    separator: ' ',
    toProps: args => {
        if (args.length > 0) {
            const path = stripQuotes(args[0]);
            return {path};
        }

        return { path: '' };
    },
    toArgs: ({ path }) => {
        return [`"${stripQuotes(path)}"`];
    },
    control: ({ path, onChange }) => {
        const theme = useTheme();

        return h('input', {
            key: 'control-input',
            value: path || undefined,
            onChange: event => {
                onChange({ path: event.target.value });
            },
            style: {
                width: 'fit-content',
                backgroundColor: theme.background.main,
                color: theme.text.primary,
                padding: '4px 8px',
            },
        });
    },
    preview: ({ path }) => h('a', {href: path}, path),
});
