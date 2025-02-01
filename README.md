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
- **Clone the Repository**:
  - git clone https://github.com/abdennour-GUESSOUM/INTAKHIBDZ
  - cd INTAKHIBDZ
- **Install Dependencies**:
  - flutter pub get
- **Set Up Firebase**:
   - Create a Firebase project and update google-services.json (Android)
- **Deploy Smart Contracts**:
  - truffle migrate --network ganache
- **Run the App**:
  - flutter run

## Usage
1. **Launch the App**: Open the app and navigate to the authentication screen.
2. **NFC Authentication**:
  - Enter the Machine Readable Zone (MRZ) code from your CNIBE.
  - Place the CNIBE card against the phone to scan via NFC.
3. **Facial Recognition**: Capture a live photo for real time identity verification.
4. **Private Key Validation**: Enter the unique private key provided post-authentication.
5. **Vote**:
  - Select a candidate/party.
  - Confirm your choice with a secure PIN.
6. **View Results**: Access real-time results post-election via the blockchain explorer once elections closed.


## Screens UI
### INTAKHIBDZ Logo
![image](https://github.com/user-attachments/assets/336e143f-029b-4762-bcd4-fdd2ffbc7e32)
### Onboarding screens
![image](https://github.com/user-attachments/assets/78ac1ad9-9ce2-466d-84aa-cde46aadd89c)
### MRZ card input
![image](https://github.com/user-attachments/assets/6c5d1470-8276-431d-a0b4-fbadd636cd88)
### ID Card (CNIBE) successfully scanned
![image](https://github.com/user-attachments/assets/6c5d1470-8276-431d-a0b4-fbadd636cd88)
### Facial authentication
#### Successfully authenticated 
![image](https://github.com/user-attachments/assets/8325c514-3903-40a1-b9e5-169955c8caba)
![image](https://github.com/user-attachments/assets/81d2079c-d302-4756-8b17-2d11a1a2cbb4)
![image](https://github.com/user-attachments/assets/fac73c09-9344-4f0a-82df-a2e3bfa2a3a1)
![image](https://github.com/user-attachments/assets/5f35ef16-5afb-47d5-944d-abcb2bceabba)
#### Failed authentication
![image](https://github.com/user-attachments/assets/c7d5e2a9-41c1-4edc-b4f1-223a1f75cd20)
### Delivered private key input
![image](https://github.com/user-attachments/assets/a58bfd40-0320-424e-904a-f976c1b62915)
![image](https://github.com/user-attachments/assets/5f6749d8-d9ce-475e-a6a3-015dea9d40a9)
### Main screens
![image](https://github.com/user-attachments/assets/54fc135f-f6c0-4edb-9d37-7edbcdf8abc8)
![image](https://github.com/user-attachments/assets/817f9445-e090-4f6b-aa67-42bc7ed0e3b0)
![image](https://github.com/user-attachments/assets/643be289-2a8f-40bb-ba2e-30062a4369e4)
![image](https://github.com/user-attachments/assets/2bf218a6-e864-483b-a255-50104dca9022)
### Diffenrent voting phases screens
![image](https://github.com/user-attachments/assets/2d2149d7-374f-46c5-8751-6f8f0c474016)
![image](https://github.com/user-attachments/assets/1ad85bbe-9bb1-41e9-9c64-e09062cd656f)
![image](https://github.com/user-attachments/assets/6da4af35-90ee-40a6-8b48-7eae5ccc346f)
![image](https://github.com/user-attachments/assets/412873c4-3b43-4dd3-a824-ea68eadad821)
![image](https://github.com/user-attachments/assets/8f62abf8-f670-49fd-ada5-ebc5050e6df3)
![image](https://github.com/user-attachments/assets/2b900257-6fa6-4e71-ab48-5ea6696e6308)
![image](https://github.com/user-attachments/assets/eaf6d812-f59d-44ed-99e6-fd2f0c833ff2)
![image](https://github.com/user-attachments/assets/9ea36ae6-e2ac-4cf1-a73e-6773641cd623)
![image](https://github.com/user-attachments/assets/7680498c-79c6-4800-80f1-ea82cb8aafe3)
![image](https://github.com/user-attachments/assets/ecc42267-43b8-428d-8844-d09333491d13)
![image](https://github.com/user-attachments/assets/520d835f-011d-4b3a-904e-e5c4a8f7b505)
### Results screens
![image](https://github.com/user-attachments/assets/8298d745-9dbe-4530-bbaf-59a4573aad71)
![image](https://github.com/user-attachments/assets/4ce120c5-b78b-4137-a187-818431e05b79)
![image](https://github.com/user-attachments/assets/20981f34-b538-4b1d-8696-d9543b951ecc)

## Acknowledgments
- **Badji Mokhtar University** - Annaba for academic support.
- **Prof. Boudour Rachid** (Thesis Advisor) for guidance.
- **Flutter**, **Firebase**, and **Truffle** communities for open-source tools.

**Note**: This project is still a prototype.



   
   




   




