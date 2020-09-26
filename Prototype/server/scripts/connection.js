exports.getConnectionDetails = function() {
    return {
        host: process.env.PGHOST || 'localhost',
        user: process.env.PGUSER || 'postgres',
        password: process.env.PGPASSWORD ||'clsec',
        database: process.env.PGDATABASE ||'postgres',
        port: process.env.PGPORT || 5432,
    }
}