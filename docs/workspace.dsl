!constant SYSTEM_NAME "POC dApp"

workspace {
    model {
        user = person "User" "A user having a wallet that supports Sui."

        game = softwareSystem "${SYSTEM_NAME}" "Allows Mysten Labs to showcase a POC." {
            group "Frontend" {
                webappComp = container "Web Application" "Delivers the UI as a single page application." "next.js"
                multiPageApplicationCont = container "Multi-Page-Application" "A single page application that the user interacts with." "React" {
                    authenticator = component "Authenticator" "Handles the user's transaction authentication." "zklogin"
                    mainComponent = component "Main Component" "Allows the user to interact with the game board and the cards." "React, Sui TS-SDK" {
                        tags "Main Component"
                    }
                    assets = component "Assets" "Contains the app's icons, look and other designs." "PNG, JPEG, SVG" {
                        tags "assets"
                    }
                    tags "SPA"
                }
            }
            group "Web3 Layer" {
                smartContractCont = container "Smart Contract" "Contains all the smart contract rules." "Sui Move" {
                    tags "smart contract"
                }
            }
        }

        # Context level relationships
        user -> game "Plays"

        # Component level relationships
        user -> multiPageApplicationCont "Signs in, starts/ends process, triggers NFT mints"
        user -> webappComp "Requests page from" "HTTP"
        webappComp -> multiPageApplicationCont "Delivers to the user's browser" "HTTP"
        multiPageApplicationCont -> smartContractCont "Makes move calls"
        authenticator -> mainComponent "Authenticates transactions of"
        assets -> mainComponent "Get displayed on"

        user -> authenticator "Signs in with"
        user -> mainComponent "Interacts with"

        mainComponent -> smartContractCont "Makes move calls to"
    }

    views {
        systemContext game "Context" {
            include *
            autolayout lr
        }

        container game "Container" {
            include *
            autolayout
        }

        component multiPageApplicationCont "Component" {
            include *
            autolayout
        }

        styles {
            element "SPA" {
                shape WebBrowser
            }
            element "assets" {
                shape Folder
            }
            element "Main Component" {
                shape Hexagon
            }
        }

        themes default
    }
}