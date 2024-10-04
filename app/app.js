import dns from 'dns/promises';
import util from 'util';
import express from 'express';
import cors from 'cors';
import { config } from 'dotenv';

config();

const nginxService = 'nginx-service';
const nginxNamespace = 'nginx-namespace';
const dnsName = `${nginxService}.${nginxNamespace}.svc.cluster.local`;
// const dnsName = `sanadedu.com`;

const app = express();
const port = process.env.PORT || 3030;

app.use(express.json());
app.use(cors());

const resolveDNS = async () => {
	try {
		const addresses = await dns.resolve(dnsName);
		return `Resolved IP addresses for ${dnsName}: ${addresses.join(', ')}`;
	} catch (err) {
		return `DNS resolution failed for ${dnsName}: ${err.message}`;
	}
};

export const continuouslyResolveDNS = async (interval = 5000) => {
	while (true) {
		console.log(await resolveDNS());
		await util.promisify(setTimeout)(interval);
	}
};

app.get('/', async (req, res) => {
	return res.status(200).send(await resolveDNS());
});

app.listen(port, () => {
	console.log(`Server is running on port ${port}`);
	continuouslyResolveDNS();
});
