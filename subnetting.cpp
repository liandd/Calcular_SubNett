#include<bits/stdc++.h>
using namespace std;

int getOctetosDeIP(string ip, vector<int> &octetosIP) {	
	stringstream sip(ip);								
	string tmp;
	octetosIP.clear();									
	vector<bool> ipEnRango;
	while (getline(sip,tmp,'.'))						
		octetosIP.push_back(atoi(tmp.c_str()));			
	if (octetosIP.size() == 4) {
		for(int i=0; i<octetosIP.size(); i++){
			if (octetosIP[i] >= 0 && octetosIP[i] <= 255)
				ipEnRango.push_back(true);
			else
				ipEnRango.push_back(false);
		}
		if (ipEnRango[0]==true&&ipEnRango[1]==true&&ipEnRango[2]==true&&ipEnRango[3]==true){
			return 0;
		}else{
			cout << "\n[!] Solo hay 255 bits por octecto. Ingresa nuevamente la IP.\n\n";
			return 1;
		}
	}else{
		cout << "\n[!] Ingresar los cuatro octetos usando puntos\n\n";
		return 1;
	}
}

int getOctetosMask(string mask, vector<int> &octetosMask) {
	stringstream smask(mask);
	string tmp;
	octetosMask.clear();		
	vector<bool> maskEnRango;
	while (getline(smask,tmp,'.'))
		octetosMask.push_back(atoi(tmp.c_str()));
	if (octetosMask.size() == 4){
		for(int i = 0; i < octetosMask.size(); i++){
			if (octetosMask[i] == 0 || octetosMask[i] == 128 || octetosMask[i] == 192 || octetosMask[i] == 224 || octetosMask[i] == 240 || octetosMask[i] == 248 || octetosMask[i] == 252 || octetosMask[i] == 254 || octetosMask[i] == 255)
				maskEnRango.push_back(true);
			else
				maskEnRango.push_back(false);
		}
		if(maskEnRango[0]==true&&maskEnRango[1]==true&&maskEnRango[2]==true&&maskEnRango[3]==true){
			return 0;
		}else{
			cout<< "\n[!] Mascaras de subnet solo usan 2^[0-7]. Ingresa nuevamente la mascara.\n\n";
			return 1;
		}
	}else{
		cout<<"\n[!] Ingresar los cuatro octetos usando puntos\n";
		return 1;
	}
}

int calcularClase(vector<int> &octetosIP) {
	if (octetosIP[0] == 10) {
		return 1;	// Class A Private address blocks //
	}else if (octetosIP[0] == 172 && octetosIP[1] >= 16 && octetosIP[1] <= 31) {
		return 2;	// Class B Private address blocks //
	}else if (octetosIP[0] == 192 && octetosIP[1] == 168) {
		return 3;	// Class C Private address blocks //
	}else if (octetosIP[0] == 127) {
		return 4;	// Loopback Address Reserved address blocks //
	}else if (octetosIP[0] >= 0 && octetosIP[0] < 127) {
		return 5;
	}else if (octetosIP[0] > 127 && octetosIP[0] < 192) {
		return 6;
	}else if (octetosIP[0] > 191 && octetosIP[0] < 224) {
		return 7;
	}else if (octetosIP[0] > 223 && octetosIP[0] < 240) {
		return 8;
	}else if (octetosIP[0] > 239 && octetosIP[0] <= 255) {
		return 9;
	}else{
		return 0;	// Out of Range //
	}
}

// Determine Binary /--
int getNumeroHBits(vector<int> &octetosIP, vector<int> &octetosMask, vector<int> &octetosIPBits, vector<int> &octetosMaskBits){

	// Get IP binary rep. //
    cout << "[!] Representacion Binaria\n\n";
	for (int j=0; j<octetosIP.size(); j++){
		if (j>0)
			cout << ".";

        int mask = 128;
        while (mask){
            octetosIPBits.push_back((octetosIP[j] & mask) != 0);
			cout << ((octetosIP[j] & mask) != 0);
            mask >>= 1;
        }
    }
	cout << "  : IP Address\n";
	// Get SUBNET binary rep. //
	for (int j=0; j < octetosMask.size(); j++){
		if (j>0)
			cout << ".";
        int mask = 128;
        while (mask){
            octetosMaskBits.push_back((octetosMask[j] & mask) != 0);
			cout << ((octetosMask[j] & mask) != 0);
            mask >>= 1;
        }
    }
	cout << "  : Subnet Mask\n\n";
return 0;
}

// Perform ANDing of IP and Subnet Mask to generate Network ID range //
vector<int> getNetID(vector<int> &octetosIPBits, vector<int> &octetosMaskBits){
	vector<int> netID;
    for (int j=0; j < octetosIPBits.size(); j++){
        if ((j > 0) && (j%8 == 0))
            cout << ".";

		netID.push_back(octetosIPBits[j] & octetosMaskBits[j]);
    }
return netID;
}


// Turn Binary back to Decimal
string toString(vector<int> octetos){
	ostringstream octStrm;
	for(int j=0; j<octetos.size(); j++){
		if (j>0)
			octStrm << '.';

		octStrm << octetos[j];
	}
	return octStrm.str();
}

// Turn Binary back to Decimal
vector<int> toDecimal(vector<int> octetos, vector<int> &decimales){
	stringstream octStrm;
	decimales.clear();
	for(int j=0; j<octetos.size(); j++){
		if (j>0)
			octStrm << '.';

		octStrm << octetos[j];
	}
	string temp;
	while (getline(octStrm, temp, '.'))
		decimales.push_back(atoi(temp.c_str()));

	return decimales;
}

// Get the network increment //
int getIncrement(vector<int> decimalMask, vector<int> decimalNetID){
	int increment = 0;
	for (int i=0; i<decimalMask.size(); i++){
		if (decimalMask[i] == 255){
			increment = 1;
		}else if(decimalMask[i] == 254){
			increment = 2;
			break;
		}else if(decimalMask[i] == 252){
			increment = 4;
			break;
		}else if(decimalMask[i] == 248){
			increment = 8;
			break;
		}else if(decimalMask[i] == 240){
			increment = 16;
			break;
		}else if(decimalMask[i] == 224){
			increment = 32;
			break;
		}else if(decimalMask[i] == 192){
			increment = 64;
			break;
		}else if(decimalMask[i] == 128){
			increment = 128;
			break;
		}
	}
return increment;
}

// get network id range
vector<int> getNetIDRange(vector<int> &decimalNetID, int &netInc, vector<int> &decimalMask) {
	vector<int> netIDEnd;
	for (int i=0; i<decimalNetID.size(); i++){
		if (decimalMask[i] == 255){
			netIDEnd.push_back(decimalNetID[i]);
		}else if (decimalMask[i] < 255 && decimalMask[i] > 0){
			netIDEnd.push_back( (decimalNetID[i] + netInc) - 1 );
		}else{
			netIDEnd.push_back(255);
		}
	}
	return netIDEnd;
}

// Get subnets
int getSubnets(vector<int> &decimalMask, int &ipClass, vector<int> &subClassMask){
	int netBits = 0;
	subClassMask.clear();
		if (ipClass==1){
			subClassMask.push_back(255);
			subClassMask.push_back(0);
			subClassMask.push_back(0);
			subClassMask.push_back(0);
		}else if(ipClass==2){
			subClassMask.push_back(255);
			subClassMask.push_back(255);
			subClassMask.push_back(0);
			subClassMask.push_back(0);
		}else if(ipClass==3){
			subClassMask.push_back(255);
			subClassMask.push_back(255);
			subClassMask.push_back(255);
			subClassMask.push_back(0);
		}else if(ipClass==4 || ipClass==5){
			subClassMask.push_back(decimalMask[0]);
			subClassMask.push_back(decimalMask[1]);
			subClassMask.push_back(decimalMask[2]);
			subClassMask.push_back(decimalMask[3]);
		}

	for (int i=0; i<decimalMask.size(); i++){
		if (decimalMask[i] != subClassMask[i]){
			if (decimalMask[i] == 255){
				netBits += 8;
				continue;
			}else if (decimalMask[i] == 254){
				netBits += 7;
				continue;
			}else if (decimalMask[i] == 252){
				netBits += 6;
				continue;
			}else if (decimalMask[i] == 248){
				netBits += 5;
				continue;
			}else if (decimalMask[i] == 240){
				netBits += 4;
				continue;
			}else if (decimalMask[i] == 224){
				netBits += 3;
				continue;
			}else if (decimalMask[i] == 192){
				netBits += 2;
				continue;
			}else if (decimalMask[i] == 128){
				netBits += 1;
				continue;
			}else if (decimalMask[i] == 0){
				netBits += 0;
				continue;
			}else{
				netBits += 0;
			}
		}
	}
	int subnets = pow(2.0,netBits);
	return subnets;
}

// Get hosts per subnet
int getHostsPerSubnet(vector<int> &decimalMask){
	int hostBits = 0;
	for (int i=0; i<decimalMask.size(); i++){
		if (decimalMask[i] == 255){
			hostBits += 0;
			continue;
		}else if (decimalMask[i] == 254){
			hostBits += 1;
			continue;
		}else if (decimalMask[i] == 252){
			hostBits += 2;
			continue;
		}else if (decimalMask[i] == 248){
			hostBits += 3;
			continue;
		}else if (decimalMask[i] == 240){
			hostBits += 4;
			continue;
		}else if (decimalMask[i] == 224){
			hostBits += 5;
			continue;
		}else if (decimalMask[i] == 192){
			hostBits += 6;
			continue;
		}else if (decimalMask[i] == 128){
			hostBits += 7;
			continue;
		}else if (decimalMask[i] == 0){
			hostBits += 8;
			continue;
		}else{
			hostBits = 0;
			break;
		}
	}
	cout<<hostBits<<":bitss\n";
	int hostsPerSubnet = pow(2.0,hostBits)-2;
	cout<<hostsPerSubnet<<":bitssPersubnet\n";
	return hostsPerSubnet;
}

int main() {

// Give details, given an IP and Subnet Mask //
char resp = 'y';
while (resp == 'y') {
        system("cls");
        cout << "[+] Calculadora IPv4\n";
		// Get IP address octets //
		string ip;
		vector<int> octetsIP;
		while (getOctetosDeIP(ip, octetsIP) == 1) {
		cout << "[!] Ingresar direccion IPv4 -> ";
		(getline(cin, ip));		// Accept user input for IP Address //
		}

		// Get subnet mask octets //
		string mask;
		vector<int> octetsMask;
		while (getOctetosMask(mask, octetsMask) == 1) {
		cout << endl << "[!] Ingresar subnet mask para la IP -> " << ip << " -> ";
		(getline(cin, mask));	// Accept user input for subnet mask //
		}
		system("cls");

		// Print Initial User IP and Subnet Mask //
		vector<int> decimals;
		cout << "[+] IP Address: " << toString(octetsIP) << "\n";
		vector<int> decimalMask = toDecimal(octetsMask, decimals);
		cout << "[+] Subnet Mask: " << toString(octetsMask) << "\n";
		cout << "" << "\n\n";

		// Print Binary Representation //
		vector<int> octetsIPBits;
		vector<int> octetsMaskBits;
		getNumeroHBits(octetsIP, octetsMask, octetsIPBits, octetsMaskBits);
		vector<int> netID = getNetID(octetsIP, octetsMask);
		vector<int> decimalNetID = toDecimal(netID, decimals);
		int netInc = getIncrement(decimalMask, decimalNetID);

		// Print IP Class
			// Run function to determine and print IP class
			cout << "\n[+] Informacion de Clase\n\n";
			int classResult = calcularClase(octetsIP);
			int ipClass = 0;
			switch (classResult){
				case 1:
					cout << "[+] IP Class: Private block, Class 'A' " << endl;
					ipClass = 1;
					break;
				case 2:
					cout << "[+] IP Class: Private block, Class 'B'" << endl;
					ipClass = 2;
					break;
				case 3:
					cout << "[+] IP Class: Private block, Class 'C'" << endl;
					ipClass = 3;
					break;
				case 4:
					cout << "[+] IP Class: Reserved block, System Loopback Address" << endl;
					ipClass = 1;
					break;
				case 5:
					cout << "[+] IP Class: A\n";
					ipClass = 1;
					break;
				case 6:
					cout << "[+] IP Class: B\n";
					ipClass = 2;
					break;
				case 7:
					cout << "[+] IP Class: C\n";
					ipClass = 3;
					break;
				case 8:
					cout << "[+] IP Class: D\n";
					ipClass = 4;
					cout << "[!]  Esta es una Clase D Reservada 'Multicast IP Address Block'\n";
					break;
				case 9:
					cout << "[+] IP Class: E\n";
					ipClass = 5;
					cout << "[!] Esta es una Clase E Reservada 'Multicast IP Address Block'\n";
					break;
				default :
					cout << "[!] No esta en rango\n";
					break;
			}
		vector<int> subClassMask;
		getSubnets(decimalMask, ipClass, subClassMask);
		cout << "[+] Default Class Subnet Mask: " << toString(subClassMask) << endl;
		cout << "\n\n";

		// Print Subnetting Details //
		cout << "[+] Subnet Details\n\n";
		cout << "[+] Total Hosts:  " << getHostsPerSubnet(decimalMask) << "\n";
		vector<int> netIDRange = getNetIDRange(decimalNetID, netInc, decimalMask);
		cout << "[+] Network ID:   "<<toString(netID)<<"\n[+] Broadcast ID: "<<toString(netIDRange)<<"\n";
		cout << "[+] Network Increment: " << getIncrement(decimalMask, decimalNetID) << endl;
		cout << "[+] Number of Subnets: " << getSubnets(decimalMask, ipClass, subClassMask) << endl;

		cout << "\n[!] Ingresar otra IP? (y or n): ";
		cin >> resp;
}
	return 0;
}