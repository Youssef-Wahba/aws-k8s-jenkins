import dns from 'dns/promises';
import util from 'util';

const nginxService = 'nginx-service';
const nginxNamespace = 'nginx-namespace';
const dnsName = `${nginxService}.${nginxNamespace}.svc.cluster.local`;
// const dnsName = `sanadedu.com`;

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

continuouslyResolveDNS();
