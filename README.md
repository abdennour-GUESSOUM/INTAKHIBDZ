# INTAKHIBDZ, an NFC and Blockchain-Based Mobile Voting System for Secure Elections  

## Overview
This project presents a secure, decentralized mobile voting application designed for presidential and legislative elections. Leveraging **NFC (Near Field Communication)** for voter authentication and **blockchain technology** for ensuring vote integrity, the system enhances electoral transparency, security, and accessibility. Developed as part of a master's thesis at Badji Mokhtar University - Annaba, Algeria, the application streamlines the voting process while addressing challenges like voter fraud, low turnout, and logistical inefficiencies.

## Features
- **NFC Authentication**: Securely authenticate voters using Algeria's National Biometric Electronic Identity Card (CNIBE).
- **Facial Recognition**: Verify voter identity via real-time facial recognition to prevent impersonation.
- **Blockchain Integration**: Immutably record votes on a blockchain (Ethereum-based) using smart contracts.
- **Multi-Factor Security**: Private key validation and encrypted transactions.
- **Real-Time Results**: Transparent, tamper-proof results accessible post-election.
- **User-Friendly Interface**: Built with Flutter for cross-platform compatibility.

## Technologies Used
- **Mobile App**: 
  - **Flutter** & **Dart** for UI/UX.
  - **Android SDK** & **NFC Reader** for CNIBE scanning.
- **Backend**: 
  - **Firebase** for authentication and data storage.
- **Blockchain**: 
  - **Solidity** for smart contracts.
  - **Truffle Framework** & **Ganache** for local blockchain deployment and testing.
- **Tools**: 
  - **Android Studio** for development.
  - **Git** for version control.

 ## Installation
1. **Clone the Repository**:
   git clone https://github.com/yourusername/mobile-voting-system.git
   cd mobile-voting-system

2. **Install Dependencies**:
   flutter pub get

3. **Set Up Firebase**:
   Create a Firebase project and add google-services.json (Android).

4. **Set Up Firebase**:
   truffle migrate --network ganache
   
5. **Run the App**:
   flutter run

## Usage
1. **Launch the App**: Open the app and navigate to the authentication screen.
2. **NFC Authentication**:
- Enter the MRZ code from your CNIBE.
- Tap the CNIBE card against the phone to scan via NFC.
3. **Facial Recognition**: Capture a live photo for identity verification.
4. **Private Key Validation**: Enter the unique private key provided post-authentication.
5. **Vote**:
- Select a candidate/party.
- Confirm your choice with a secure PIN.
6. **View Results**: Access real-time results post-election via the blockchain explorer once elections closed.

## Acknowledgments

- **Badji Mokhtar University** - Annaba for academic support.

- **Prof. Boudour Rachid** (Thesis Advisor) for guidance.

- **Flutter**, **Firebase**, and **Truffle** communities for open-source tools.


**Note**: This project is a prototype. Always ensure compliance with local electoral laws before deployment.



   
   




   




