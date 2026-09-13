import { knex as setUpKnex, Knex } from "knex"
import { env } from './env'

export const config: Knex.Config = {
    client: 'sqlite',
    connection: {
        filename: env.DATABASE_URL,
    },
    useNullAsDefault: true,
    migrations: {
        extension: 'ts',
        directory: './db/migrations',
        loadExtensions: ['.ts']
    }
}

export const knex = setUpKnex(config)