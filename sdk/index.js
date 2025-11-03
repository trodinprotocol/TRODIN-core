// sdk/index.js
class TRODINPay {
  constructor({ apiKey, apiUrl = "https://api.trodinpay.com" }) {
    this.apiKey = apiKey;
    this.apiUrl = apiUrl;
  }

  async mint({ amountUSD, playerAddress, webhookUrl }) {
    const response = await fetch(`${this.apiUrl}/create-checkout-session`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": this.apiKey,
      },
      body: JSON.stringify({
        amountUSD,
        playerAddress,
        webhookUrl,
      }),
    });

    const data = await response.json();
    if (!response.ok) throw new Error(data.error || "Mint failed");

    return data;
  }
}

export { TRODINPay };
