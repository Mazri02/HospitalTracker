<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="csrf-token" content="{{ csrf_token() }}">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Hospital Tracker Playground</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Styles / Scripts -->
        @if (file_exists(public_path('build/manifest.json')) || file_exists(public_path('hot')))
            @vite(['resources/css/app.css', 'resources/js/app.js'])
        @else
            <style>
                /* ! tailwindcss v3.4.1 | MIT License | https://tailwindcss.com */*,::after,::before{box-sizing:border-box;border-width:0;border-style:solid;border-color:#e5e7eb}::after,::before{--tw-content:''}:host,html{line-height:1.5;-webkit-text-size-adjust:100%;-moz-tab-size:4;tab-size:4;font-family:Figtree, ui-sans-serif, system-ui, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji;font-feature-settings:normal;font-variation-settings:normal;-webkit-tap-highlight-color:transparent}body{margin:0;line-height:inherit}hr{height:0;color:inherit;border-top-width:1px}abbr:where([title]){-webkit-text-decoration:underline dotted;text-decoration:underline dotted}h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}a{color:inherit;text-decoration:inherit}b,strong{font-weight:bolder}code,kbd,pre,samp{font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;font-feature-settings:normal;font-variation-settings:normal;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}table{text-indent:0;border-color:inherit;border-collapse:collapse}button,input,optgroup,select,textarea{font-family:inherit;font-feature-settings:inherit;font-variation-settings:inherit;font-size:100%;font-weight:inherit;line-height:inherit;color:inherit;margin:0;padding:0}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button;background-color:transparent;background-image:none}:-moz-focusring{outline:auto}:-moz-ui-invalid{box-shadow:none}progress{vertical-align:baseline}::-webkit-inner-spin-button,::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}blockquote,dd,dl,figure,h1,h2,h3,h4,h5,h6,hr,p,pre{margin:0}fieldset{margin:0;padding:0}legend{padding:0}menu,ol,ul{list-style:none;margin:0;padding:0}dialog{padding:0}textarea{resize:vertical}input::placeholder,textarea::placeholder{opacity:1;color:#9ca3af}[role=button],button{cursor:pointer}:disabled{cursor:default}audio,canvas,embed,iframe,img,object,svg,video{display:block;vertical-align:middle}img,video{max-width:100%;height:auto}[hidden]{display:none}*, ::before, ::after{--tw-border-spacing-x:0;--tw-border-spacing-y:0;--tw-translate-x:0;--tw-translate-y:0;--tw-rotate:0;--tw-skew-x:0;--tw-skew-y:0;--tw-scale-x:1;--tw-scale-y:1;--tw-pan-x: ;--tw-pan-y: ;--tw-pinch-zoom: ;--tw-scroll-snap-strictness:proximity;--tw-gradient-from-position: ;--tw-gradient-via-position: ;--tw-gradient-to-position: ;--tw-ordinal: ;--tw-slashed-zero: ;--tw-numeric-figure: ;--tw-numeric-spacing: ;--tw-numeric-fraction: ;--tw-ring-inset: ;--tw-ring-offset-width:0px;--tw-ring-offset-color:#fff;--tw-ring-color:rgb(59 130 246 / 0.5);--tw-ring-offset-shadow:0 0 #0000;--tw-ring-shadow:0 0 #0000;--tw-shadow:0 0 #0000;--tw-shadow-colored:0 0 #0000;--tw-blur: ;--tw-brightness: ;--tw-contrast: ;--tw-grayscale: ;--tw-hue-rotate: ;--tw-invert: ;--tw-saturate: ;--tw-sepia: ;--tw-drop-shadow: ;--tw-backdrop-blur: ;--tw-backdrop-brightness: ;--tw-backdrop-contrast: ;--tw-backdrop-grayscale: ;--tw-backdrop-hue-rotate: ;--tw-backdrop-invert: ;--tw-backdrop-opacity: ;--tw-backdrop-saturate: ;--tw-backdrop-sepia: }::backdrop{--tw-border-spacing-x:0;--tw-border-spacing-y:0;--tw-translate-x:0;--tw-translate-y:0;--tw-rotate:0;--tw-skew-x:0;--tw-skew-y:0;--tw-scale-x:1;--tw-scale-y:1;--tw-pan-x: ;--tw-pan-y: ;--tw-pinch-zoom: ;--tw-scroll-snap-strictness:proximity;--tw-gradient-from-position: ;--tw-gradient-via-position: ;--tw-gradient-to-position: ;--tw-ordinal: ;--tw-slashed-zero: ;--tw-numeric-figure: ;--tw-numeric-spacing: ;--tw-numeric-fraction: ;--tw-ring-inset: ;--tw-ring-offset-width:0px;--tw-ring-offset-color:#fff;--tw-ring-color:rgb(59 130 246 / 0.5);--tw-ring-offset-shadow:0 0 #0000;--tw-ring-shadow:0 0 #0000;--tw-shadow:0 0 #0000;--tw-shadow-colored:0 0 #0000;--tw-blur: ;--tw-brightness: ;--tw-contrast: ;--tw-grayscale: ;--tw-hue-rotate: ;--tw-invert: ;--tw-saturate: ;--tw-sepia: ;--tw-drop-shadow: ;--tw-backdrop-blur: ;--tw-backdrop-brightness: ;--tw-backdrop-contrast: ;--tw-backdrop-grayscale: ;--tw-backdrop-hue-rotate: ;--tw-backdrop-invert: ;--tw-backdrop-opacity: ;--tw-backdrop-saturate: ;--tw-backdrop-sepia: }.absolute{position:absolute}.relative{position:relative}.-left-20{left:-5rem}.top-0{top:0px}.-bottom-16{bottom:-4rem}.-left-16{left:-4rem}.-mx-3{margin-left:-0.75rem;margin-right:-0.75rem}.mt-4{margin-top:1rem}.mt-6{margin-top:1.5rem}.flex{display:flex}.grid{display:grid}.hidden{display:none}.aspect-video{aspect-ratio:16 / 9}.size-12{width:3rem;height:3rem}.size-5{width:1.25rem;height:1.25rem}.size-6{width:1.5rem;height:1.5rem}.h-12{height:3rem}.h-40{height:10rem}.h-full{height:100%}.min-h-screen{min-height:100vh}.w-full{width:100%}.w-\[calc\(100\%\+8rem\)\]{width:calc(100% + 8rem)}.w-auto{width:auto}.max-w-\[877px\]{max-width:877px}.max-w-2xl{max-width:42rem}.flex-1{flex:1 1 0%}.shrink-0{flex-shrink:0}.grid-cols-2{grid-template-columns:repeat(2, minmax(0, 1fr))}.flex-col{flex-direction:column}.items-start{align-items:flex-start}.items-center{align-items:center}.items-stretch{align-items:stretch}.justify-end{justify-content:flex-end}.justify-center{justify-content:center}.gap-2{gap:0.5rem}.gap-4{gap:1rem}.gap-6{gap:1.5rem}.self-center{align-self:center}.overflow-hidden{overflow:hidden}.rounded-\[10px\]{border-radius:10px}.rounded-full{border-radius:9999px}.rounded-lg{border-radius:0.5rem}.rounded-md{border-radius:0.375rem}.rounded-sm{border-radius:0.125rem}.bg-\[\#FF2D20\]\/10{background-color:rgb(255 45 32 / 0.1)}.bg-white{--tw-bg-opacity:1;background-color:rgb(255 255 255 / var(--tw-bg-opacity))}.bg-gradient-to-b{background-image:linear-gradient(to bottom, var(--tw-gradient-stops))}.from-transparent{--tw-gradient-from:transparent var(--tw-gradient-from-position);--tw-gradient-to:rgb(0 0 0 / 0) var(--tw-gradient-to-position);--tw-gradient-stops:var(--tw-gradient-from), var(--tw-gradient-to)}.via-white{--tw-gradient-to:rgb(255 255 255 / 0)  var(--tw-gradient-to-position);--tw-gradient-stops:var(--tw-gradient-from), #fff var(--tw-gradient-via-position), var(--tw-gradient-to)}.to-white{--tw-gradient-to:#fff var(--tw-gradient-to-position)}.stroke-\[\#FF2D20\]{stroke:#FF2D20}.object-cover{object-fit:cover}.object-top{object-position:top}.p-6{padding:1.5rem}.px-6{padding-left:1.5rem;padding-right:1.5rem}.py-10{padding-top:2.5rem;padding-bottom:2.5rem}.px-3{padding-left:0.75rem;padding-right:0.75rem}.py-16{padding-top:4rem;padding-bottom:4rem}.py-2{padding-top:0.5rem;padding-bottom:0.5rem}.pt-3{padding-top:0.75rem}.text-center{text-align:center}.font-sans{font-family:Figtree, ui-sans-serif, system-ui, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji}.text-sm{font-size:0.875rem;line-height:1.25rem}.text-sm\/relaxed{font-size:0.875rem;line-height:1.625}.text-xl{font-size:1.25rem;line-height:1.75rem}.font-semibold{font-weight:600}.text-black{--tw-text-opacity:1;color:rgb(0 0 0 / var(--tw-text-opacity))}.text-white{--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity))}.underline{-webkit-text-decoration-line:underline;text-decoration-line:underline}.antialiased{-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}.shadow-\[0px_14px_34px_0px_rgba\(0\2c 0\2c 0\2c 0\.08\)\]{--tw-shadow:0px 14px 34px 0px rgba(0,0,0,0.08);--tw-shadow-colored:0px 14px 34px 0px var(--tw-shadow-color);box-shadow:var(--tw-ring-offset-shadow, 0 0 #0000), var(--tw-ring-shadow, 0 0 #0000), var(--tw-shadow)}.ring-1{--tw-ring-offset-shadow:var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) var(--tw-ring-offset-color);--tw-ring-shadow:var(--tw-ring-inset) 0 0 0 calc(1px + var(--tw-ring-offset-width)) var(--tw-ring-color);box-shadow:var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow, 0 0 #0000)}.ring-transparent{--tw-ring-color:transparent}.ring-white\/\[0\.05\]{--tw-ring-color:rgb(255 255 255 / 0.05)}.drop-shadow-\[0px_4px_34px_rgba\(0\2c 0\2c 0\2c 0\.06\)\]{--tw-drop-shadow:drop-shadow(0px 4px 34px rgba(0,0,0,0.06));filter:var(--tw-blur) var(--tw-brightness) var(--tw-contrast) var(--tw-grayscale) var(--tw-hue-rotate) var(--tw-invert) var(--tw-saturate) var(--tw-sepia) var(--tw-drop-shadow)}.drop-shadow-\[0px_4px_34px_rgba\(0\2c 0\2c 0\2c 0\.25\)\]{--tw-drop-shadow:drop-shadow(0px 4px 34px rgba(0,0,0,0.25));filter:var(--tw-blur) var(--tw-brightness) var(--tw-contrast) var(--tw-grayscale) var(--tw-hue-rotate) var(--tw-invert) var(--tw-saturate) var(--tw-sepia) var(--tw-drop-shadow)}.transition{transition-property:color, background-color, border-color, fill, stroke, opacity, box-shadow, transform, filter, -webkit-text-decoration-color, -webkit-backdrop-filter;transition-property:color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;transition-property:color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter, -webkit-text-decoration-color, -webkit-backdrop-filter;transition-timing-function:cubic-bezier(0.4, 0, 0.2, 1);transition-duration:150ms}.duration-300{transition-duration:300ms}.selection\:bg-\[\#FF2D20\] *::selection{--tw-bg-opacity:1;background-color:rgb(255 45 32 / var(--tw-bg-opacity))}.selection\:text-white *::selection{--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity))}.selection\:bg-\[\#FF2D20\]::selection{--tw-bg-opacity:1;background-color:rgb(255 45 32 / var(--tw-bg-opacity))}.selection\:text-white::selection{--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity))}.hover\:text-black:hover{--tw-text-opacity:1;color:rgb(0 0 0 / var(--tw-text-opacity))}.hover\:text-black\/70:hover{color:rgb(0 0 0 / 0.7)}.hover\:ring-black\/20:hover{--tw-ring-color:rgb(0 0 0 / 0.2)}.focus\:outline-none:focus{outline:2px solid transparent;outline-offset:2px}.focus-visible\:ring-1:focus-visible{--tw-ring-offset-shadow:var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) var(--tw-ring-offset-color);--tw-ring-shadow:var(--tw-ring-inset) 0 0 0 calc(1px + var(--tw-ring-offset-width)) var(--tw-ring-color);box-shadow:var(--tw-ring-offset-shadow), var(--tw-ring-shadow), var(--tw-shadow, 0 0 #0000))}.focus-visible\:ring-\[\#FF2D20\]:focus-visible{--tw-ring-opacity:1;--tw-ring-color:rgb(255 45 32 / var(--tw-ring-opacity))}@media (min-width: 640px){.sm\:size-16{width:4rem;height:4rem}.sm\:size-6{width:1.5rem;height:1.5rem}.sm\:pt-5{padding-top:1.25rem}}@media (min-width: 768px){.md\:row-span-3{grid-row:span 3 / span 3}}@media (min-width: 1024px){.lg\:col-start-2{grid-column-start:2}.lg\:h-16{height:4rem}.lg\:max-w-7xl{max-width:80rem}.lg\:grid-cols-3{grid-template-columns:repeat(3, minmax(0, 1fr))}.lg\:grid-cols-2{grid-template-columns:repeat(2, minmax(0, 1fr))}.lg\:flex-col{flex-direction:column}.lg\:items-end{align-items:flex-end}.lg\:justify-center{justify-content:center}.lg\:gap-8{gap:2rem}.lg\:p-10{padding:2.5rem}.lg\:pb-10{padding-bottom:2.5rem}.lg\:pt-0{padding-top:0px}.lg\:text-\[\#FF2D20\]{--tw-text-opacity:1;color:rgb(255 45 32 / var(--tw-text-opacity))}}@media (prefers-color-scheme: dark){.dark\:block{display:block}.dark\:hidden{display:none}.dark\:bg-black{--tw-bg-opacity:1;background-color:rgb(0 0 0 / var(--tw-bg-opacity))}.dark\:bg-zinc-900{--tw-bg-opacity:1;background-color:rgb(24 24 27 / var(--tw-bg-opacity))}.dark\:via-zinc-900{--tw-gradient-to:rgb(24 24 27 / 0)  var(--tw-gradient-to-position);--tw-gradient-stops:var(--tw-gradient-from), #18181b var(--tw-gradient-via-position), var(--tw-gradient-to)}.dark\:to-zinc-900{--tw-gradient-to:#18181b var(--tw-gradient-to-position)}.dark\:text-white\/50{color:rgb(255 255 255 / 0.5)}.dark\:text-white{--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity))}.dark\:text-white\/70{color:rgb(255 255 255 / 0.7)}.dark\:ring-zinc-800{--tw-ring-opacity:1;--tw-ring-color:rgb(39 39 42 / var(--tw-ring-opacity))}.dark\:hover\:text-white:hover{--tw-text-opacity:1;color:rgb(255 255 255 / var(--tw-text-opacity))}.dark\:hover\:text-white\/70:hover{color:rgb(255 255 255 / 0.7)}.dark\:hover\:text-white\/80:hover{color:rgb(255 255 255 / 0.8)}.dark\:hover\:ring-zinc-700:hover{--tw-ring-opacity:1;--tw-ring-color:rgb(63 63 70 / var(--tw-ring-opacity))}.dark\:focus-visible\:ring-\[\#FF2D20\]:focus-visible{--tw-ring-opacity:1;--tw-ring-color:rgb(255 45 32 / var(--tw-ring-opacity))}.dark\:focus-visible\:ring-white:focus-visible{--tw-ring-opacity:1;--tw-ring-color:rgb(255 255 255 / var(--tw-ring-opacity))}
            </style>
        @endif
    </head>
    <body class="font-sans antialiased dark:text-white/50">
        <div class="bg-gray-50 text-black/50 dark:text-white/50 flex flex-wrap justify-center">
            <div class="w-full my-auto h-[100vh] hidden" id='login-page'>
                <div class="w-[50%] flex p-6 border-black border-r-[.125em] border-t-[.125em] border-b-[.125em]">
                    <form class="flex flex-col w-1/2 bg-gray-500 p-6 rounded-xl m-4 gap-4 h-fit my-auto" id="login-form-doctor">
                        @csrf
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        <h1 class="text-center text-black font-bold text-xl">User Doctor : Create</h1>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Doctor Name" name="UserName" type='text'/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Doctor Email" name="UserEmail" type='text'/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Doctor Password" name="UserPassword" type='text'/>
                        <input class="px-2 py-1 rounded-md bg-white text-black" placeholder="Doctor Picture" name="DoctorPict" type='file'/>
                        <button type="submit" class="bg-blue-500 rounded-xl text-white p-2">Submit</button>
                    </form>

                    <form class="flex flex-col w-1/2 bg-gray-500 p-6 rounded-xl m-4 gap-4 h-fit my-auto" id="login-doctor">
                        @csrf
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        <h1 class="text-center text-black font-bold text-xl">Login : Doctor</h1>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Email" name="UserEmail" type='text'/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Password" name="UserPassword" type='text'/>
                        <button type="submit" class="bg-blue-500 rounded-xl text-white p-2">Submit</button>
                    </form>
                </div>
                
                <div class="w-[50%] flex p-6 border-black border-r-[.125em] border-t-[.125em] border-b-[.125em]">
                    <form class="flex flex-col w-[50%] bg-gray-500 p-6 rounded-xl m-4 gap-4 h-fit my-auto" id="login-form-user">
                        @csrf
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        <h1 class="text-center text-black font-bold text-xl">Register : User</h1>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Email" name="UserEmail" type='text'/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Name" name="UserName" type='text'/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Password" name="UserPassword" type='text'/>
                        <button type="submit" class="bg-blue-500 rounded-xl text-white p-2">Submit</button>
                    </form>

                    <form class="flex flex-col w-[50%] bg-gray-500 p-6 rounded-xl m-4 gap-4 h-fit my-auto" id="login-user">
                        @csrf
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        <h1 class="text-center text-black font-bold text-xl">Login : User</h1>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Email" name="UserEmail" type='text'/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Password" name="UserPassword" type='text'/>
                        <button type="submit" class="bg-blue-500 rounded-xl text-white p-2">Submit</button>
                    </form>
                </div>
            </div>
            
            <div class="w-full hidden" id="dashboard-interface">
                <div class="w-full flex mt-4">
                    <div class="my-auto"><span class="text-center text-black font-bold text-xl m-4 hidden w-full" id="username">Welcome <span id="type"></span>, <span id="name"></h1></span></div>
                    <div class="flex">
                        <button class="bg-gray-500 px-2 py-1 rounded-md text-white hidden" id="doctor-badge">Doctor Interface</button>
                        <button class="bg-gray-500 px-2 py-1 rounded-md text-white hidden" id="user-badge">User Interface</button>
                        <form id="logout-form">
                            @csrf
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        	<button class="bg-red-500 px-2 py-1 rounded-md text-white" id='logout' type="submit">Logout</button>
			            </form>
                    </div>
                </div>
                <div class="flex flex-wrap justify-center">
                    <div class='w-1/4 flex gap-4 m-4' id='edit-profile'>
                        <form class="flex flex-col w-full bg-gray-500 p-6 rounded-xl gap-4 h-fit my-auto" id="doctor">
                            @csrf
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                            <img class="w-[35%] mx-auto" id="DoctorPict"/>
                            <h1 class="text-center text-black font-bold text-xl">Doctor Profile</h1>
                            <input class="px-2 py-1 rounded-md text-black" placeholder="Doctor Name" name="UserName" type='text'/>
                            <input class="px-2 py-1 rounded-md text-black" placeholder="Doctor Email" name="UserEmail" type='text'/>
                            <input class="px-2 py-1 rounded-md text-black" placeholder="Change Password" name="UserPassword" type='text'/>
                            <input class="px-2 py-1 rounded-md bg-white text-black" placeholder="Doctor Picture" name="DoctorPict" type='file'/>
                            <div class="w-full flex gap-2">
                                <button type="button" class="w-full bg-red-500 rounded-xl text-white p-2 deleteAccount">Delete</button>
                                <button type="submit" class="w-full bg-blue-500 rounded-xl text-white p-2">Submit</button>
                            </div>
                        </form>
                        <form class="flex flex-col w-full bg-gray-500 p-6 rounded-xl gap-4 h-fit my-auto hidden" id="user">
                            @csrf
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                            <h1 class="text-center text-black font-bold text-xl">User Profile</h1>
                            <input class="px-2 py-1 rounded-md text-black" placeholder="Email" name="UserEmail" type='text'/>
                            <input class="px-2 py-1 rounded-md text-black" placeholder="Name" name="UserName" type='text'/>
                            <input class="px-2 py-1 rounded-md text-black" placeholder="Change Password" name="UserPassword" type='text'/>
                            
                            <div class="w-full flex gap-2">
                                <button type="button" class="w-full bg-red-500 rounded-xl text-white p-2 deleteAccount">Delete</button>
                                <button type="submit" class="w-full bg-blue-500 rounded-xl text-white p-2">Submit</button>
                            </div>
                        </form>
                    </div>

                    <form class="flex flex-col w-[25%] bg-gray-500 p-6 rounded-xl m-4 gap-4 h-fit hidden" id="hospital">
                        @csrf
                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        <h1 class="text-center text-black font-bold text-xl font-bold">Location Hospital : Create</h1>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Hospital Name" type='text' name="HospitalName"/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Hospital Latitude" type='number' name="HospitalLang"/>
                        <input class="px-2 py-1 rounded-md text-black" placeholder="Hospital Longitude" type='number' name="HospitalLong"/>
                        <textarea class="px-2 py-1 rounded-md text-black" placeholder="Hospital Address" name="HospitalAddress"></textarea>
                        <input class="px-2 py-1 rounded-md bg-white text-black" placeholder="Hospital Picture" type='file' name="HospitalPict"/>
                        <button type="submit" class="bg-blue-500 rounded-xl text-white p-2">Submit</button>
                    </form>

                    <div class="w-[30%] overflow-y-auto h-[50%] bg-gray-500 m-4 rounded-xl text-[1.15em] text-black">
                        <h1 class="py-2 text-center font-bold">Location Hospital : View All</h1>
                        <div class="bg-gray-500" id="allHospital"></div>
                    </div>

                    <div class="w-[30%] overflow-y-auto h-[50%] bg-gray-500 m-4 rounded-xl text-[.85em] hidden text-black" id="showDetails">
                        <div class="w-full bg-black"><img id="select_HospitalPict" class="w-[50%] mx-auto"/></div>
                        <div class="text-left p-4"> 
                            <h1>Hospital Name : <span id="select_HospitalName"></span></h1>
                            <span>Hospital Latitude : <span id="select_HospitalLang"></span></span><br/>
                            <span>Hospital Longitude : <span id="select_HospitalLong"></span></span><br/>
                            <span>Hospital Address : <span id="select_HospitalAddress"></span></span><br/>
                        </div>
                        <div class="text-left p-4 border-t-[.125em] border-black flex"> 
                            <img id="select_DoctorPicture" class="w-[20%] h-[20vh] mr-4"/>
                            <div class="my-auto">
                                <span>Assigned Doctor : <span id="select_DoctorName">Not Assigned</span></span><br/>
                                <span>Doctor Email : <span id="select_DoctorEmail">Not Assigned</span></span><br/>
                                <span>Total Reviews : <span id="select_TotalReviews">0 Reviews</span></span><br/>
                            </div>
                        </div>
                        <div class="text-left px-4 border-t-[.125em] border-black gap-4 hidden" id="form-user-action"> 
                            <form id="appointment">
                                @csrf
                                <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                <input class="w-full py-1 px-2 mt-4 rounded-md" type="text" placeholder="Reason for Visit" name="reasonAppoint"/>
                                <input class="w-full py-1 px-2 mt-4 rounded-md" type="datetime-local" name="timeAppoint">
                            </form>
                        </div>

                        <div class="w-full">
                            <div class="mx-4 flex gap-4 hidden" id="doctor-action">
                                <button class="bg-green-500 w-full rounded-xl text-white p-2 my-4" id="assignhospital">Assign</button>
                                <button class="bg-blue-500 w-full rounded-xl text-white p-2 my-4 hidden" id="unassignhospital">Leave</button>
                                <button class="bg-red-500 w-full rounded-xl text-white p-2 my-4" id="deletehospital">Delete</button>
                                <button class="bg-blue-500 w-full rounded-xl text-white p-2 my-4 viewAppoint">Appointment</button>
                            </div>
                            <div class="mx-4 flex gap-4 hidden" id="user-action">
                                <button class="bg-green-500 w-full rounded-xl text-white p-2 my-4" id="bookAppoint">Book</button>
                                <button class="bg-blue-500 w-full rounded-xl text-white p-2 my-4 viewAppoint">Appointment</button>
                            </div>
                        </div>
                    </div> 
                    
                    <div class="w-[30%] overflow-y-auto h-[50%] bg-gray-500 m-4 rounded-xl text-[1.15em] text-black hidden" id="user-appointment">
                        <h1 class="py-2 text-center font-bold">Hospital Appointment</h1>
                        <div class="bg-gray-500" id="allappointment"></div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script>
            $(document).ready(function() {
                // Set up CSRF token for all AJAX requests
                $.ajaxSetup({
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    }
                });

                let token = localStorage.getItem('token');
                let name = localStorage.getItem('name');
                let type = localStorage.getItem('type');
                let id = localStorage.getItem('id');

                if(token && token != undefined){
                    $('#name').text(name)
                    $('#name').show()
                    $('#username').show()
                    $('#login-page').hide()
                    $('#dashboard-interface').show()
                    $("#type").text(type)

                    if(type == "doctor"){
                        $('#doctor-badge').show()
                        $('#hospital').css('display','flex')
                        $('#doctor-action').css('display','flex')
                        $('#edit-profile #doctor').css('display','flex')
                        $('#edit-profile #user').hide()

                        fetch("/api/GetUserData/"+id+"/"+type, {
                            method: "GET",
                            headers : {
                                'Authorization': "Bearer " + localStorage.getItem('token'),
                                'Accept': 'application/json',
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                            },
                        })
                        .then((res) => {
                            if(res.ok) {
                                return res.json();
                            }
                            throw new Error('Network response was not ok');
                        })
                        .then((data)=>{
                            let value = data.data;   
                            $("#edit-profile #doctor input[name='UserName']").val(value.UserName);
                            $("#edit-profile #doctor input[name='UserEmail']").val(value.UserEmail);
                            $("#edit-profile #doctor #DoctorPict").attr('src',value.DoctorPict);
                        })
                    }

                    if(type == "user"){                        
                        $('#edit-profile #doctor').hide()
                        $('#edit-profile #user').css('display','flex')
                        $('#user-badge').show()
                        $('#user-action').css('display','flex')
                        $('#form-user-action').css('display','flex')

                        fetch("/api/GetUserData/"+id+"/"+type, {
                            method: "GET",
                            headers : {
                                'Authorization': "Bearer " + localStorage.getItem('token'),
                                'Accept': 'application/json',
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                            },
                        })
                        .then((res) => {
                            if(res.ok) {
                                return res.json();
                            }
                            throw new Error('Network response was not ok');
                        })
                        .then((data)=>{
                            let value = data.data;   
                            $("#edit-profile #user input[name='UserName']").val(value.UserName);
                            $("#edit-profile #user input[name='UserEmail']").val(value.UserEmail);
                        })
                    }

                    fetch("/api/AllHospital", {
                        method: "GET",
                        headers : {
                            'Authorization': "Bearer " + token,
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        }
                    })
                    .then((res) => {
                        if(res.ok) {
                            return res.json();
                        }
                        throw new Error('Network response was not ok');
                    })
                    .then((data) => {
                        let hospital = "";
                        for(var i = 0;i < data.length;i++){
                            hospital += `
                            <div class='flex bg-gray-500 border-t border-black hover:cursor-pointer hover:bg-gray-400 selecthospital' id='${data[i].HospitalID}'>
                                <img src='${data[i].HospitalPicture}' class='bg-black h-full w-[35%] mx-2'/>
                                <div class='text-left my-auto text-[.75em]'>
                                    <h1>Hospital Name : ${data[i].HospitalName}</h1>
                                    <div>Latitude: ${data[i].HospitalLong}</div>
                                    <div>Longitude: ${data[i].HospitalLang}</div>
                                    <div>Address: ${data[i].HospitalAddress}</div>
                                </div>
                            </div>
                            `;
                        }
                        $('#allHospital').html(hospital)
                    })
                    .catch((error) => {
                        console.error('Error:', error);
                    });
                } else {
                    $('#dashboard-interface').hide()
                    $('#login-page').css('display','flex')
                }
            })

            $(document).on('click','#assignhospital', function(e){
                e.preventDefault();
                let DoctorID = localStorage.getItem('id');
                let hospitalID = localStorage.getItem('hostid');
                fetch("/api/AssignHospital/"+DoctorID+"/"+hospitalID+"", {
                    method: "POST",
                    headers : {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                }).then((res)=>{
                    if(res.status == 200){
                        location.reload()
                    } else {
                        alert("Failed")
                    }
                })
            })

            $(document).on('click','#bookAppoint', function(e){
                e.preventDefault();
                let UserID = localStorage.getItem('id');
                let AssignID = localStorage.getItem('assignID');
                
                let formData = new FormData($('#appointment')[0]);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/BookAppointment/"+UserID+"/"+AssignID+"", {
                    method: "POST",
                    headers: {
                        'Authorization': 'Bearer ' + localStorage.getItem('token')
                    },
                    body: formData
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Appointment booked successfully!");
                    location.reload();
                })
                .catch((error) => {
                    console.error('Error:', error);
                    alert("Failed to book appointment: " + error.message);
                });
            });

            $(document).on('click','#unassignhospital', function(e){
                e.preventDefault();
                let DoctorID = localStorage.getItem('id');
                let hospitalID = localStorage.getItem('hostid');
                fetch("/api/LeaveHospital/"+DoctorID+"/"+hospitalID+"", {
                    method: "POST",
                    headers : {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                }).then((res)=>{
                    if(res.status == 200){
                        location.reload()
                    } else {
                        alert("Failed")
                    }
                })
            })

            $(document).on('click','#deletehospital', function(e){
                e.preventDefault();
                let hospitalID = localStorage.getItem('hostid');
                fetch("/api/DeleteHospital/"+hospitalID+"", {
                    method: "DELETE",
                    headers : {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                }).then((res)=>{
                    if(res.status == 200){
                        alert("Success")
                        location.reload()
                    } else {
                        alert("Failed")
                    }
                })
            })
            
            $(document).on('click', '.cancelAppoint', function(e) {
                e.preventDefault();
                fetch("/api/CancelAppointment/"+this.id, {
                    method: "DELETE",
                    headers : {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                }).then((res)=>{
                    if(res.status == 200){
                        location.reload()
                    } else {
                        alert("Failed")
                    }
                })
            })

            $(document).on('click', '.deleteReviews', function(e) {
                e.preventDefault();
                fetch("/api/DeleteReview/"+this.id, {
                    method: "DELETE",
                    headers : {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                }).then((res)=>{
                    if(res.status == 200){
                        location.reload()
                    } else {
                        alert("Failed")
                    }
                })
            })

            $(document).on('submit', '.submitReview', function(e) {
                e.preventDefault();
                let formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/SubmitReview/"+this.id, {
                    method: "POST",
                    headers: {
                        'Authorization': 'Bearer ' + localStorage.getItem('token')
                    },
                    body: formData
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Review submitted successfully!");
                    location.reload();
                })
                .catch((error) => {
                    console.error('Error:', error);
                    alert("Failed to submit review: " + error.message);
                });
            })

            $(document).on('click', '.viewAppoint', function(e) {
                e.preventDefault();
                let hostid = localStorage.getItem('hostid');
                let id = localStorage.getItem('id');
                let type = localStorage.getItem('type');

                if(type == 'user') {
                    fetch("/api/SelectAppointment/" + hostid + "/" + id, {
                        method: "GET",
                        headers: {
                            'Authorization': "Bearer " + localStorage.getItem("token"),
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        }
                    })
                    .then((res) => {
                        if(res.ok) {
                            return res.json();
                        }
                        throw new Error('Network response was not ok');
                    })
                    .then((data) => {
                        let appoint = "";

                        for(var i = 0; i < data.length; i++) {
                            const hasReviews = data[i].Ratings != null && data[i].Reviews != null;
                            
                            appoint += 
                            `<div class='flex w-full bg-gray-500 border-t border-black hover:cursor-pointer hover:bg-gray-400 p-2'>
                                <div class='text-left my-auto text-[.75em] w-full'>
                                    <h1>Reason Visit : ${data[i].ReasonVisit}</h1>
                                    <div>Status Appointment: ${data[i].Status}</div>
                                    <div>Date: ${data[i].AssignDate} </div>
                                    <div class='${hasReviews ? '' : 'hidden'}' id='formReviews-${data[i].AppoinmentID}'>
                                        <div>Ratings: ${data[i].Ratings || ''}</div>
                                        <div>Reviews: ${data[i].Reviews || ''}</div>
                                    </div>

                                    <form class='w-full mt-2 gap-2 flex flex-col submitReview' id='${data[i].AppoinmentID}'>
                                        <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                        <div class='${hasReviews ? 'hidden' : ''} gap-2 flex flex-col'>
                                            <input class='w-full p-2 rounded-md' type='text' name='reviews' placeholder='Insert Reviews'/>
                                            <input class='w-full p-2 rounded-md' type='number' min='0' max='5' name='ratings' placeholder='Submit Ratings 1 - 5'/>
                                        </div>
                                        <div class='flex w-full gap-2'>
                                            <button class='bg-red-500 px-2 py-1 w-full text-white rounded-md mt-2 cancelAppoint' id='${data[i].AppoinmentID}' type='submit'>Cancel</button>
                                            <button class='bg-blue-500 px-2 py-1 w-full text-white rounded-md mt-2 ${hasReviews ? 'hidden' : ''}' id='${data[i].AppoinmentID}' type='submit'>Review</button>
                                            <button class='bg-red-600 px-2 py-1 w-full text-white rounded-md mt-2 ${!hasReviews ? 'hidden' : ''} deleteReviews' id='${data[i].AppoinmentID}' type='submit'>Delete Review</button>
                                        </div>
                                    </form>
                                </div>
                            </div>`;
                        }
                        
                        $('#user-appointment').show();

                        if(data.length > 0) {
                            $('#allappointment').html(appoint);
                        } else {
                            $('#allappointment').html("<div class='text-center w-full my-6 text-[.85em]'>No appointments found</div>");
                        }
                    })
                    .catch((error) => {
                        console.error('Error:', error);
                    });
                } else {
                    fetch("/api/AllAppointment/" + hostid, {
                        method: "GET",
                        headers: {
                            'Authorization': "Bearer " + localStorage.getItem("token"),
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        }
                    })
                    .then((res) => {
                        if(res.ok) {
                            return res.json();
                        }
                        throw new Error('Network response was not ok');
                    })
                    .then((data) => {
                        let appoint = "";
                        for(var i = 0; i < data.length; i++) {
                            const hasReviews = data[i].Ratings != null && data[i].Reviews != null;
                            
                            appoint += 
                            `<div class='flex w-full bg-gray-500 border-t border-black hover:cursor-pointer hover:bg-gray-400 p-2'>
                                <form>
                                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                                    <div class='text-left my-auto text-[.75em] w-full'>
                                        <h1>Reason Visit : ${data[i].ReasonVisit}</h1>
                                        <div>Status Appointment: ${data[i].Status}</div>
                                        <div>Date: ${data[i].AssignDate} </div>
                                        <div class='${hasReviews ? '' : 'hidden'}' id='formReviews-${data[i].AppoinmentID}'>
                                            <div>Ratings: ${data[i].Ratings || ''}</div>
                                            <div>Reviews: ${data[i].Reviews || ''}</div>
                                        </div>
                                        
                                        <div class='flex w-full gap-2 ${!hasReviews ? '' : 'hidden'}'>
                                            <button class='bg-red-500 px-2 py-1 w-full text-white rounded-md mt-2 updateAppoint' id='${data[i].AppoinmentID}' type='button'>Reject</button>
                                            <button class='bg-green-500 px-2 py-1 w-full text-white rounded-md mt-2 updateAppoint' id='${data[i].AppoinmentID}' type='button'>Accept</button>
                                        </div>
                                    </div>
                                </form>
                            </div>`;
                        }
                        
                        $('#user-appointment').show();

                        if(data.length > 0) {
                            $('#allappointment').html(appoint);
                        } else {
                            $('#allappointment').html("<div class='text-center w-full my-6 text-[.85em]'>No appointments found</div>");
                        }
                    })
                    .catch((error) => {
                        console.error('Error:', error);
                    });
                }
            });

            $(document).on('click', '.selecthospital', function(e) {
                e.preventDefault();
                $('#user-appointment').hide()

                fetch("/api/ViewHospital/"+this.id, {
                    method: "GET",
                    headers : {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    }
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json(); 
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    $('#select_HospitalName').text(data.HospitalName);
                    $('#select_HospitalLang').text(data.HospitalLang);
                    $('#select_HospitalLong').text(data.HospitalLong);
                    $('#select_HospitalAddress').text(data.HospitalAddress);
                    $('#select_HospitalPict').attr('src',data.HospitalPicture);
                    if(data.DoctorID != null){
                        $("#select_DoctorName").text(data.DoctorName);
                        $('#select_DoctorPicture').show();
                        $('#select_DoctorEmail').text(data.DoctorEmail);
                        $('#select_DoctorPicture').attr('src',data.DoctorPict)
                        $('#unassignhospital').show();
                        $('#assignhospital').hide();
                        localStorage.setItem("assignID",data.AssignID);
                    } else {
                        $("#select_DoctorName").text("Not Assigned");
                        $('#select_DoctorEmail').text("Not Assigned");
                        $('#select_DoctorPicture').hide();
                        $('#unassignhospital').hide();
                        $('#assignhospital').show();
                        localStorage.removeItem("assignID");
                    }

                    $('#showDetails').show();
                    localStorage.setItem("hostid", this.id);
                })
                .catch((error) => {
                    console.error('Error:', error);
                });
            });

            $(document).on('click','.updateAppoint', function(e) {
                e.preventDefault();
                fetch("/api/UpdateAppointment/" +this.id + "/" + $(this).text(), {
                    method: "POST",
                    headers: {
                        'Authorization': "Bearer " + localStorage.getItem('token'),
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    }
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json(); 
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    location.reload()
                })
                .catch((error) => {
                    alert("Failed");
                    console.error('Error:', error);
                });
            })

            $('#login-doctor').on('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/LoginDoctor", {
                    method: "POST",
                    body: formData,
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json(); 
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    localStorage.setItem("token", data.token);
                    localStorage.setItem("name", data.data.UserName);
                    localStorage.setItem("id", data.data.UserID);
                    localStorage.setItem("type", "doctor");
                    location.reload()
                })
                .catch((error) => {
                    alert("Failed");
                    console.error('Error:', error);
                });
            })

            $('#login-user').on('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/LoginUser", {
                    method: "POST",
                    body: formData,
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json(); 
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    localStorage.setItem("token", data.token);
                    localStorage.setItem("name", data.data.UserName);
                    localStorage.setItem("id", data.data.UserID);
                    localStorage.setItem("type", "user");
                    location.reload()
                })
                .catch((error) => {
                    alert("Failed");
                    console.error('Error:', error);
                });
            })

            $('.deleteAccount').on('click', function(e) {
                e.preventDefault();
                let id = localStorage.getItem('id');
                let type = localStorage.getItem('type');

                fetch("/api/DeleteUser/"+id+"/"+type, {
                    method: "DELETE",
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('token')}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                })
                .then((res) => {
                    if (res.ok) {
                        localStorage.removeItem("token");
                        localStorage.removeItem("name");
                        localStorage.removeItem("id");
                        localStorage.removeItem("type");
                        location.reload()
                    } else {
                        throw new Error('Logout failed');
                    }
                })
                .catch((error) => {
                    alert("Failed to logout");
                    console.error('Error:', error);
                });
            });

            $('#logout-form').on('submit', function(e) {
                e.preventDefault();
                let id = localStorage.getItem('id');

                fetch("/api/logout/"+id, {
                    method: "POST",
                    headers: {
                        'Authorization': `Bearer ${localStorage.getItem('token')}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                })
                .then((res) => {
                    if (res.ok) {
                        localStorage.removeItem("token");
                        localStorage.removeItem("name");
                        localStorage.removeItem("id");
                        localStorage.removeItem("type");
                        location.reload()
                    } else {
                        throw new Error('Logout failed');
                    }
                })
                .catch((error) => {
                    alert("Failed to logout");
                    console.error('Error:', error);
                });
            });

            $('#login-form-doctor').on('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));

                fetch("/api/RegisterDoctor", {
                    method: "POST",
                    body: formData
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Success");
                    console.log(data);
                })
                .catch((error) => {
                    alert("Failed");
                    console.error('Error:', error);
                });
            });

            $('#edit-profile #doctor').on('submit', function(e) {
                e.preventDefault();
                let id = localStorage.getItem('id');
                let type = localStorage.getItem('type');
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/EditUser/" + id + "/" + type, {
                    method: "POST",
                    headers: {
                        'Authorization': 'Bearer ' + localStorage.getItem('token')
                    },
                    body: formData
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Profile updated successfully!");
                    location.reload();
                })
                .catch((error) => {
                    alert("Failed to update profile: " + error.message);
                    console.error('Error:', error);
                });
            });

            $('#edit-profile #user').on('submit', function(e) {
                e.preventDefault();
                let id = localStorage.getItem('id');
                let type = localStorage.getItem('type');
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/EditUser/" + id + "/" + type, {
                    method: "POST",
                    headers: {
                        'Authorization': 'Bearer ' + localStorage.getItem('token')
                    },
                    body: formData
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Profile updated successfully!");
                    location.reload();
                })
                .catch((error) => {
                    alert("Failed to update profile: " + error.message);
                    console.error('Error:', error);
                });
            });

            $('#login-form-user').on('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/RegisterUser", {
                    method: "POST",
                    body: formData,
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Success");
                    console.log(data);
                })
                .catch((error) => {
                    alert("Failed");
                    console.error('Error:', error);
                });
            });

            $('#hospital').on('submit', function(e) {
                e.preventDefault();
                
                const formData = new FormData(this);
                formData.append('_token', document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
                
                fetch("/api/RegisterHospital", {
                    method: "POST",
                    body: formData,
                    headers: {
                        'Authorization': "Bearer " + localStorage.getItem('token')
                    }
                })
                .then((res) => {
                    if(res.ok) {
                        return res.json();
                    }
                    throw new Error('Network response was not ok');
                })
                .then((data) => {
                    alert("Success");
                    location.reload()
                })
                .catch((error) => {
                    alert(error);
                    console.error('Error:', error);
                });
            });
        </script>
    </body>
</html>