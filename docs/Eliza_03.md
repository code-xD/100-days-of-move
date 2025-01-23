# Move Bot Day 03: Deploying Trump character on telegram
> Today we will be deploying trump character based AI agent on telegram. Join [this group](https://t.me/+HzTYUNYoQaM0YjQ1) to interact with the bot
## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
  - [API Keys](#api-keys)
  - [Character Configuration](#character-configuration)
- [Running the Bot](#running-the-bot)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before getting started, ensure you have the following:

- Node.js (latest LTS version recommended)
- pnpm package manager
- Git
- API keys:
  - Anthropic API Key
  - Telegram Bot Token

## Installation

1. Clone the Eliza repository:
   ```bash
   git clone https://github.com/elizaos/eliza.git
   cd eliza
   ```

2. Checkout the latest release:
   ```bash
   git checkout $(git describe --tags --abbrev=0)
   # Alternative method if above doesn't work:
   # git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
   ```

3. Install dependencies and build the project:
   ```bash
   pnpm clean
   pnpm i
   pnpm build
   ```

## Configuration

### API Keys

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Obtain and Configure API Keys:

   #### Anthropic API Key
   - Visit [Anthropic Developer Portal](https://docs.anthropic.com/en/api/getting-started)
   - Create an account and generate an API key
   - Add the key to `.env` file:
     ```
     ANTHROPIC_API_KEY=your_anthropic_api_key_here
     ```

   #### Telegram Bot Token
   - Visit [BotFather on Telegram](https://t.me/botfather)
   - Create a new bot and obtain the bot token
   - Add the token to `.env` file:
     ```
     TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here
     ```

### Character Configuration

Edit the character configuration file `./characters/trump.character.json`:

```json
{
    "name": "Trump",
    "modelProvider": "anthropic",
    "clients": ["telegram"]
    // Add other character-specific configurations
}
```

#### Character Configuration Fields
- `name`: Name of the character/bot
- `modelProvider`: AI model provider (e.g., "anthropic", "openai")
- `clients`: Supported platforms (e.g., "telegram", "discord")

## Running the Bot

Run the bot with the specified character configuration:

```bash
pnpm start --characters="./characters/trump.character.json"
```

## Troubleshooting

- Ensure all API keys are correctly set in the `.env` file
- Verify that you have the latest version of dependencies
- Use `pnpm clean` if you encounter dependency issues

## Advanced Configuration

For advanced users, you can modify default character settings in:
`packages/core/src/defaultCharacter.ts`

## References

- [Eliza GitHub Repository](https://github.com/elizaOS/eliza)
- [Anthropic API Documentation](https://docs.anthropic.com/en/api/getting-started)
- [Telegram Bot API](https://core.telegram.org/api)

